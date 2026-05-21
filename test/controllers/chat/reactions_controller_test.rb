require "test_helper"

class Chat::ReactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room = rooms(:one)
    @message = messages(:one)
    @user_name = "TestUser"
    post chat_set_name_path, params: { user_name: @user_name }
  end

  test "should create reaction with valid emoji" do
    assert_difference("Reaction.count", 1) do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "👍" }
    end

    assert_response :created
    reaction = Reaction.last
    assert_equal @user_name, reaction.user_name
    assert_equal @message, reaction.message
    assert_equal "👍", reaction.emoji
  end

  test "should create reaction with turbo_stream format" do
    assert_difference("Reaction.count", 1) do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "👍" }, as: :turbo_stream
    end

    assert_response :success
    reaction = Reaction.last
    assert_equal @user_name, reaction.user_name
    assert_equal "👍", reaction.emoji
  end

  test "should create reaction with all allowed emojis" do
    Reaction::ALLOWED_EMOJIS.each do |emoji|
      initial_count = Reaction.count
      post chat_room_message_reactions_path(@room, @message), params: { emoji: emoji }
      assert_response :created
      assert_equal initial_count + 1, Reaction.count
      assert_equal emoji, Reaction.last.emoji
      Reaction.last.destroy
    end
  end

  test "should toggle reaction when reaction already exists (delete existing)" do
    existing_reaction = Reaction.create!(message: @message, user_name: @user_name, emoji: "👍")
    reaction_id = existing_reaction.id

    assert_difference("Reaction.count", -1) do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "👍" }
    end

    assert_response :created
    assert_nil Reaction.find_by(id: reaction_id)
  end

  test "should not create reaction with invalid emoji" do
    assert_no_difference("Reaction.count") do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "❌" }
    end

    assert_response :unprocessable_entity
  end

  test "should not create reaction with empty emoji" do
    assert_no_difference("Reaction.count") do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "" }
    end

    assert_response :unprocessable_entity
  end

  test "should not create reaction without emoji parameter" do
    assert_no_difference("Reaction.count") do
      post chat_room_message_reactions_path(@room, @message), params: {}
    end

    assert_response :unprocessable_entity
  end

  test "should not create reaction without user_name in session" do
    post chat_set_name_path, params: { user_name: nil }

    assert_no_difference("Reaction.count") do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "👍" }
    end

    assert_response :unprocessable_entity
  end

  test "should destroy own reaction" do
    reaction = Reaction.create!(message: @message, user_name: @user_name, emoji: "👍")

    assert_difference("Reaction.count", -1) do
      delete chat_room_message_reaction_path(@room, @message, reaction)
    end

    assert_response :no_content
    assert_nil Reaction.find_by(id: reaction.id)
  end

  test "should destroy own reaction with turbo_stream format" do
    reaction = Reaction.create!(message: @message, user_name: @user_name, emoji: "👍")

    assert_difference("Reaction.count", -1) do
      delete chat_room_message_reaction_path(@room, @message, reaction), as: :turbo_stream
    end

    assert_response :success
    assert_nil Reaction.find_by(id: reaction.id)
  end

  test "should not destroy another user's reaction" do
    reaction = Reaction.create!(message: @message, user_name: "OtherUser", emoji: "👍")

    assert_no_difference("Reaction.count") do
      delete chat_room_message_reaction_path(@room, @message, reaction)
    end

    assert_response :forbidden
    assert Reaction.exists?(id: reaction.id)
  end

  test "should not destroy non-existent reaction" do
    assert_no_difference("Reaction.count") do
      delete chat_room_message_reaction_path(@room, @message, 99999)
    end

    assert_response :not_found
  end

  test "should route POST to create action" do
    assert_routing(
      { method: :post, path: "/chat/rooms/#{@room.id}/messages/#{@message.id}/reactions" },
      { controller: "chat/reactions", action: "create", room_id: @room.id.to_s, message_id: @message.id.to_s }
    )
  end

  test "should route DELETE to destroy action" do
    reaction = reactions(:one)
    assert_routing(
      { method: :delete, path: "/chat/rooms/#{@room.id}/messages/#{@message.id}/reactions/#{reaction.id}" },
      { controller: "chat/reactions", action: "destroy", room_id: @room.id.to_s, message_id: @message.id.to_s, id: reaction.id.to_s }
    )
  end

  test "should use session user_name when creating reaction" do
    different_user = "AnotherUser"
    post chat_set_name_path, params: { user_name: different_user }

    post chat_room_message_reactions_path(@room, @message), params: { emoji: "👍" }

    assert_equal different_user, Reaction.last.user_name
  end

  test "should handle concurrent toggle requests correctly" do
    Reaction.create!(message: @message, user_name: @user_name, emoji: "👍")

    assert_difference("Reaction.count", -1) do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "👍" }
    end

    assert_response :created

    assert_difference("Reaction.count", 1) do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "👍" }
    end

    assert_response :created
  end

  test "should not toggle to a different emoji, only toggle same emoji" do
    Reaction.create!(message: @message, user_name: @user_name, emoji: "👍")

    assert_difference("Reaction.count", -1) do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "👍" }
    end

    assert_response :created

    assert_difference("Reaction.count", 1) do
      post chat_room_message_reactions_path(@room, @message), params: { emoji: "❤️" }
    end

    assert_response :created
    assert_equal "❤️", Reaction.last.emoji
  end
end
