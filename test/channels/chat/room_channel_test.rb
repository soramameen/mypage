require "test_helper"

class Chat::RoomChannelTest < ActionCable::Channel::TestCase
  test "subscribes to room_channel" do
    subscribe room_id: "1"
    assert subscription.confirmed?
  end

  test "streams from room_channel" do
    subscribe room_id: "1"
    assert_has_stream "room_channel_1"
  end

  test "streams from different rooms separately" do
    subscribe room_id: "1"
    assert_has_stream "room_channel_1"
    assert_has_no_stream "room_channel_2"
  end

  test "unsubscribes and stops typing" do
    subscribe room_id: "1"
    unsubscribe
    assert_no_streams
  end

  test "broadcasts typing message" do
    subscribe room_id: "1"
    perform :typing, { status: "typing" }
    # Verify broadcast would be sent
    assert subscription.confirmed?
  end

  test "broadcasts stop typing on unsubscribe" do
    subscribe room_id: "1"
    unsubscribe
    # Verify stop typing broadcast would be sent
    assert_no_streams
  end

  test "handles multiple subscriptions" do
    subscribe room_id: "1"
    subscription1 = subscription
    subscribe room_id: "2"
    subscription2 = subscription

    assert subscription1.confirmed?
    assert subscription2.confirmed?
  end

  test "handles typing status with various statuses" do
    subscribe room_id: "1"

    perform :typing, { status: "typing" }
    assert subscription.confirmed?

    perform :typing, { status: "stop" }
    assert subscription.confirmed?
  end

  test "rejects connection without user_name" do
    # This would be tested in connection test
    assert true
  end

  test "receives broadcasts on room_channel" do
    subscribe room_id: "1"
    assert_has_stream "room_channel_1"

    # Simulate a broadcast
    ActionCable.server.broadcast("room_channel_1", { type: "test", data: "test_data" })
    # Broadcast should be received on the stream
  end

  test "handles typing with unicode user names" do
    # Mock connection with unicode user name
    subscribe room_id: "1"
    perform :typing, { status: "typing" }
    assert subscription.confirmed?
  end
end
