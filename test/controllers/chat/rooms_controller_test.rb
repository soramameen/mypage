require "test_helper"

class Chat::RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room = rooms(:one)
    post chat_set_name_path, params: { user_name: "TestUser" }
  end

  test "should get chat index" do
    get chat_path
    assert_response :success
    assert_select "h1", text: /チャットルーム|Rooms/i
  end

  test "should get index" do
    get chat_rooms_path
    assert_response :success
    assert_select "h1", text: /チャットルーム|Rooms/i
  end

  test "should get show" do
    get chat_room_path(@room)
    assert_response :success
    assert_select "h1", text: @room.name
  end

  test "should create room with valid name" do
    assert_difference("Room.count") do
      post chat_rooms_path, params: { room: { name: "New Room" } }
    end

    assert_redirected_to chat_room_path(Room.last)
  end

  test "should not create room with empty name" do
    assert_no_difference("Room.count") do
      post chat_rooms_path, params: { room: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create room with nil name" do
    assert_no_difference("Room.count") do
      post chat_rooms_path, params: { room: { name: nil } }
    end

    assert_response :unprocessable_entity
  end

  test "should show all rooms on index" do
    rooms_to_create = [ "Room A", "Room B", "Room C" ]
    rooms_to_create.each { |name| Room.create!(name: name) }

    get chat_rooms_path
    rooms_to_create.each do |name|
      assert_select "a", text: name
    end
  end

  test "should render index with errors when creation fails" do
    post chat_rooms_path, params: { room: { name: "" } }
    assert_response :unprocessable_entity
    assert_select "form[action='#{chat_rooms_path}']"
  end

  test "should handle duplicate room names" do
    Room.create!(name: "Duplicate")

    assert_no_difference("Room.count") do
      post chat_rooms_path, params: { room: { name: "Duplicate" } }
    end

    assert_response :unprocessable_entity
  end

  test "should show room with messages" do
    @room.messages.destroy_all  # 既存のメッセージを削除
    @room.messages.create!(content: "Test Message", user_name: "TestUser")

    get chat_room_path(@room)
    assert_response :success
    assert_select "div.message", count: 1
  end

  test "should show room with no messages" do
    empty_room = Room.create!(name: "Empty Room")

    get chat_room_path(empty_room)
    assert_response :success
  end

  test "should handle special characters in room name" do
    special_name = "🎉Special Room!@#$%"

    assert_difference("Room.count") do
      post chat_rooms_path, params: { room: { name: special_name } }
    end

    assert_redirected_to chat_room_path(Room.last)
  end

  test "should handle very long room names" do
    long_name = "a" * 500

    assert_difference("Room.count") do
      post chat_rooms_path, params: { room: { name: long_name } }
    end

    assert_redirected_to chat_room_path(Room.last)
  end

  test "should create room with turbo_stream format" do
    assert_difference("Room.count") do
      post chat_rooms_path, params: { room: { name: "Turbo Room" } }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should get index with user_name in session" do
    get chat_rooms_path
    assert_response :success
  end

  test "should get index without user_name in session" do
    post chat_set_name_path, params: { user_name: nil }
    get chat_rooms_path
    assert_response :success
  end
end
