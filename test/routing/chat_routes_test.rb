require "test_helper"

class ChatRoutesTest < ActionDispatch::IntegrationTest
  test "should route to chat rooms index" do
    assert_routing(
      { method: :get, path: "/chat/rooms" },
      { controller: "chat/rooms", action: "index" }
    )
  end

  test "should route to chat rooms show" do
    assert_routing(
      { method: :get, path: "/chat/rooms/1" },
      { controller: "chat/rooms", action: "show", id: "1" }
    )
  end

  test "should route to chat rooms create" do
    assert_routing(
      { method: :post, path: "/chat/rooms" },
      { controller: "chat/rooms", action: "create" }
    )
  end

  test "should route to chat messages create (nested)" do
    assert_routing(
      { method: :post, path: "/chat/rooms/1/messages" },
      { controller: "chat/messages", action: "create", room_id: "1" }
    )
  end

  test "should route to chat message edit" do
    assert_routing(
      { method: :get, path: "/chat/messages/1/edit" },
      { controller: "chat/messages", action: "edit", id: "1" }
    )
  end

  test "should route to chat message update" do
    assert_routing(
      { method: :patch, path: "/chat/messages/1" },
      { controller: "chat/messages", action: "update", id: "1" }
    )
  end

  test "should route to chat message destroy" do
    assert_routing(
      { method: :delete, path: "/chat/messages/1" },
      { controller: "chat/messages", action: "destroy", id: "1" }
    )
  end

  test "should route to chat reactions create (nested)" do
    assert_routing(
      { method: :post, path: "/chat/rooms/1/messages/1/reactions" },
      { controller: "chat/reactions", action: "create", room_id: "1", message_id: "1" }
    )
  end

  test "should route to chat reaction destroy (nested)" do
    assert_routing(
      { method: :delete, path: "/chat/rooms/1/messages/1/reactions/1" },
      { controller: "chat/reactions", action: "destroy", room_id: "1", message_id: "1", id: "1" }
    )
  end

  test "should route to chat set_name" do
    assert_routing(
      { method: :post, path: "/chat/set_name" },
      { controller: "chat/sessions", action: "create" }
    )
  end

  test "should provide chat_rooms_path helper" do
    assert_equal "/chat/rooms", chat_rooms_path
  end

  test "should provide chat_room_path helper" do
    assert_equal "/chat/rooms/1", chat_room_path(1)
  end

  test "should provide chat_set_name_path helper" do
    assert_equal "/chat/set_name", chat_set_name_path
  end

  test "should provide chat_room_messages_path helper" do
    assert_equal "/chat/rooms/1/messages", chat_room_messages_path(1)
  end

  test "should provide chat_message_path helper" do
    assert_equal "/chat/messages/1", chat_message_path(1)
  end

  test "should provide chat_edit_message_path helper" do
    assert_equal "/chat/messages/1/edit", edit_chat_message_path(1)
  end

  test "should provide chat_room_message_reactions_path helper" do
    assert_equal "/chat/rooms/1/messages/1/reactions", chat_room_message_reactions_path(1, 1)
  end

  test "should provide chat_room_message_reaction_path helper" do
    assert_equal "/chat/rooms/1/messages/1/reactions/1", chat_room_message_reaction_path(1, 1, 1)
  end

  test "should provide chat_path helper" do
    assert_equal "/chat", chat_path
  end
end
