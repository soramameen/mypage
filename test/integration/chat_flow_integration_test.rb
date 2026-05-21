require "test_helper"

class ChatFlowIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @room = Room.create!(name: "Test Room")
    @user_name = "TestUser-#{Time.now.to_i}"
    @other_user_name = "OtherUser-#{Time.now.to_i}"
  end

  # ========== 統合テスト IT-001: 新規メッセージ作成のフロー ==========
  test "IT-001: 新規メッセージ作成の統合フロー" do
    initial_count = @room.messages.count

    # Set user name
    post "/chat/set_name", params: { user_name: @user_name }
    assert_redirected_to chat_rooms_path

    # Navigate to room
    get chat_room_path(@room)
    assert_response :success

    # Post message
    post chat_room_messages_path(@room), params: { message: { content: "New test message" } }
    assert_response :success

    # Verify message was created
    assert_equal initial_count + 1, @room.messages.count
    assert_equal "New test message", @room.messages.last.content
  end

  # ========== 統合テスト IT-008: チャットルーム間でのデータ分離 ==========
  test "IT-008: チャットルーム間でのデータ分離" do
    room2 = Room.create!(name: "Second Room")

    # Create message in room 1
    @room.messages.create!(content: "Message for room 1", user_name: @user_name)

    # Create message in room 2
    room2.messages.create!(content: "Message for room 2", user_name: @user_name)

    # Verify messages are separated
    get chat_room_path(@room)
    assert_response :success
    assert_match "Message for room 1", response.body

    get chat_room_path(room2)
    assert_response :success
    assert_match "Message for room 2", response.body

    # Verify counts
    assert_equal 1, @room.messages.count
    assert_equal 1, room2.messages.count
  end

  # ========== エッジケース EC-001: 超長メッセージの送信 ==========
  test "EC-001: 超長メッセージの送信" do
    long_message = "A" * 2000

    post chat_room_messages_path(@room), params: { message: { content: long_message, user_name: @user_name } }

    assert_response :success
    assert Message.exists?(content: long_message, room_id: @room.id)
  end

  # ========== エッジケース EC-002: 特殊文字を含むメッセージの送信 ==========
  test "EC-002: 特殊文字を含むメッセージの送信" do
    html_content = "<script>alert('xss')</script>"

    post chat_room_messages_path(@room), params: { message: { content: html_content, user_name: @user_name } }

    assert_response :success
    # Content should be saved but not executed
    assert Message.exists?(content: html_content, room_id: @room.id)
  end

  # ========== エッジケース EC-005: 存在しないメッセージの編集・削除 ==========
  test "EC-005: 存在しないメッセージの編集・削除" do
    non_existent_id = 999999

    # Try to edit non-existent message
    get edit_chat_message_path(non_existent_id)
    assert_response :not_found

    # Try to delete non-existent message
    delete chat_message_path(non_existent_id)
    assert_response :not_found
  end

  # ========== エッジケース EC-010: 空メッセージ送信の防止 ==========
  test "EC-010: 空メッセージ送信の防止" do
    initial_count = @room.messages.count

    post chat_room_messages_path(@room), params: { message: { content: "", user_name: @user_name } }

    # Depending on implementation, either 422 or 200 is acceptable
    # The important thing is that no message was created
    assert_equal initial_count, @room.messages.count
  end

  # ========== リアクションの統合テスト ==========
  test "IT-007: 複数のリアクションが正しくカウントされる" do
    message = @room.messages.create!(content: "Test message", user_name: @user_name)

    # Add reactions from different users
    post chat_room_message_reactions_path(@room, message, emoji: "👍"), params: { user_name: @user_name }
    assert_response :success

    user2_name = "User2-#{Time.now.to_i}"
    post chat_room_message_reactions_path(@room, message, emoji: "👍"), params: { user_name: user2_name }
    assert_response :success

    # Verify reactions
    assert_equal 2, message.reactions.where(emoji: "👍").count
  end

  # ========== リアクションのトグルテスト ==========
  test "IT-008: リアクションのトグル動作" do
    message = @room.messages.create!(content: "Test message", user_name: @user_name)

    # Add reaction
    post chat_room_message_reactions_path(@room, message, emoji: "👍"), params: { user_name: @user_name }
    assert_response :success
    assert_equal 1, message.reactions.where(emoji: "👍", user_name: @user_name).count

    # Toggle (remove) reaction
    delete chat_room_message_reaction_path(@room, message, "👍", user_name: @user_name)
    assert_response :success
    assert_equal 0, message.reactions.where(emoji: "👍", user_name: @user_name).count
  end
end
