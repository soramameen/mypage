require "test_helper"

class Chat::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room = rooms(:one)
    @message = messages(:one)
    post chat_set_name_path, params: { user_name: "TestUser" }
  end

  test "should create message with html format" do
    assert_difference("Message.count") do
      post chat_room_messages_path(@room), params: { message: { content: "New message content" } }
    end

    assert_redirected_to chat_room_path(@room)
    assert_equal "TestUser", Message.last.user_name
  end

  test "should create message with turbo_stream format" do
    assert_difference("Message.count") do
      post chat_room_messages_path(@room), params: { message: { content: "Turbo message" } }, as: :turbo_stream
    end

    assert_response :success
    assert_match /turbo-stream action="replace" target="new_message"/, response.body
    assert_equal "TestUser", Message.last.user_name
  end

  test "should get edit" do
    get edit_chat_message_path(@message)
    assert_response :success
  end

  test "should update message" do
    patch chat_message_path(@message), params: { message: { content: "Updated content" } }
    assert_redirected_to chat_room_path(@message.room)
    @message.reload
    assert_equal "Updated content", @message.content
  end

  test "should destroy message" do
    assert_difference("Message.count", -1) do
      delete chat_message_path(@message)
    end

    assert_redirected_to chat_room_path(@message.room)
  end

  test "should not create message without content" do
    assert_no_difference("Message.count") do
      post chat_room_messages_path(@room), params: { message: { content: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create message without user_name in session" do
    post chat_set_name_path, params: { user_name: nil }

    assert_no_difference("Message.count") do
      post chat_room_messages_path(@room), params: { message: { content: "Test" } }
    end

    assert_response :unprocessable_entity
  end

  test "should create message with session user_name" do
    post chat_set_name_path, params: { user_name: "Alice" }

    post chat_room_messages_path(@room), params: { message: { content: "Alice's message" } }

    assert_equal "Alice", Message.last.user_name
  end

  test "should update message with turbo_stream format" do
    patch chat_message_path(@message), params: { message: { content: "Turbo update" } }, as: :turbo_stream

    assert_response :success
    @message.reload
    assert_equal "Turbo update", @message.content
  end

  test "should destroy message with turbo_stream format" do
    assert_difference("Message.count", -1) do
      delete chat_message_path(@message), as: :turbo_stream
    end

    assert_response :success
  end

  test "should handle special characters in message content" do
    special_content = "🎉Special message!@#$%\nNew line"

    assert_difference("Message.count") do
      post chat_room_messages_path(@room), params: { message: { content: special_content } }
    end

    assert_equal special_content, Message.last.content
  end

  test "should handle very long message content" do
    long_content = "a" * 10000

    assert_difference("Message.count") do
      post chat_room_messages_path(@room), params: { message: { content: long_content } }
    end

    assert_equal long_content, Message.last.content
  end

  test "should not update non-existent message" do
    assert_no_difference("Message.count") do
      patch chat_message_path(99999), params: { message: { content: "Test" } }
    end

    assert_response :not_found
  end

  test "should not destroy non-existent message" do
    assert_no_difference("Message.count") do
      delete chat_message_path(99999)
    end

    assert_response :not_found
  end

  test "should show edit page with current message content" do
    get edit_chat_message_path(@message)
    assert_response :success
    assert_select "textarea[name='message[content]']", text: @message.content
  end

  test "should create message with empty user_name in session" do
    post chat_set_name_path, params: { user_name: "" }

    assert_no_difference("Message.count") do
      post chat_room_messages_path(@room), params: { message: { content: "Test" } }
    end

    assert_response :unprocessable_entity
  end
end
