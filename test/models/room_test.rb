require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "should be valid with a name" do
    # Clean up all rooms first
    Room.where.not(id: rooms(:one).id).where.not(id: rooms(:two).id).destroy_all

    room = Room.new(name: "Unique-#{Time.now.to_f}-#{rand(1000)}")
    assert room.valid?, "Room validation errors: #{room.errors.full_messages.join(', ')}"
  end

  test "should be invalid without a name" do
    room = Room.new(name: nil)
    assert_not room.valid?
  end

  test "should have many messages" do
    room = Room.create!(name: "Test Room")
    assert_respond_to room, :messages
  end

  test "should destroy messages when destroyed" do
    room = Room.create!(name: "Test Room")
    room.messages.create!(content: "Test Message", user_name: "TestUser")
    message_id = room.messages.first.id

    assert_difference("Message.count", -1) do
      room.destroy
    end

    assert_nil Message.find_by(id: message_id)
  end

  test "should have unique names" do
    Room.create!(name: "Duplicate")
    duplicate_room = Room.new(name: "Duplicate")
    assert_not duplicate_room.valid?
  end

  test "should not allow empty name" do
    room = Room.new(name: "")
    assert_not room.valid?
  end
end
