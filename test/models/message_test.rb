require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @room = rooms(:one)
  end

  test "should satisfy validation" do
    # Create a fresh room to avoid conflicts
    room = Room.create!(name: "Unique-Validation-#{Time.now.to_f}-#{rand(1000)}")
    message = Message.new(content: "Hello", room: room, user_name: "TestUser")

    # Debug output
    unless message.valid?
      Rails.logger.error "Message validation errors: #{message.errors.full_messages.join(', ')}"
      Rails.logger.error "Message content: #{message.content}"
      Rails.logger.error "Message room: #{message.room&.name}"
      Rails.logger.error "Message user_name: #{message.user_name}"
      Rails.logger.error "Message errors: #{message.errors.inspect}"
    end

    assert message.valid?, "Message validation errors: #{message.errors.full_messages.join(', ')}"
  end

  test "should not save message without content" do
    message = Message.new(content: nil, room: @room)
    assert_not message.valid?
    assert_not message.save
  end

  test "should not save message without room" do
    message = Message.new(content: "Hello", room: nil)
    assert_not message.valid?
  end

  test "should not save message with empty content" do
    message = Message.new(content: "", room: @room)
    assert_not message.valid?
  end

  test "should belong to room" do
    message = messages(:one)
    assert_equal rooms(:one), message.room
  end

  test "should have many reactions" do
    message = messages(:one)
    assert_respond_to message, :reactions
  end

  test "should destroy reactions when destroyed" do
    # Create fresh data to avoid fixture conflicts
    room = Room.create!(name: "Unique-Destroy-#{Time.now.to_f}-#{rand(1000)}")
    message = room.messages.create!(content: "Test Message", user_name: "TestUser")
    reaction = message.reactions.create!(user_name: "TestUser2", emoji: "👍")
    reaction_id = reaction.id

    assert_difference("Reaction.count", -1) do
      message.destroy
    end

    assert_nil Reaction.find_by(id: reaction_id)
  end

  test "should create message with user_name" do
    message = Message.new(content: "Test", room: @room, user_name: "Alice")
    assert message.valid?
    assert_equal "Alice", message.user_name
  end

  test "should not create message without user_name" do
    message = Message.new(content: "Test", room: @room, user_name: nil)
    assert_not message.valid?
  end
end
