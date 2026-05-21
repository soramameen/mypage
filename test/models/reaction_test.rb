require "test_helper"

class ReactionTest < ActiveSupport::TestCase
  setup do
    @message = messages(:one)
    @message2 = messages(:two)
  end

  test "should create valid reaction" do
    reaction = Reaction.new(message: @message, user_name: "Charlie", emoji: "👍")
    assert reaction.valid?
  end

  test "should not save reaction without emoji" do
    reaction = Reaction.new(message: @message, user_name: "Charlie", emoji: nil)
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], "can't be blank"
    assert_not reaction.save
  end

  test "should not save reaction with empty emoji" do
    reaction = Reaction.new(message: @message, user_name: "Charlie", emoji: "")
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], "can't be blank"
    assert_not reaction.save
  end

  test "should only allow allowed emojis" do
    Reaction::ALLOWED_EMOJIS.each do |valid_emoji|
      reaction = Reaction.new(message: @message, user_name: "Charlie", emoji: valid_emoji)
      assert reaction.valid?, "Should be valid with emoji: #{valid_emoji}"
    end
  end

  test "should not save reaction with invalid emoji" do
    invalid_emojis = [ "❌", "🚫", "xyz", "test", "😭", "😡" ]
    invalid_emojis.each do |invalid_emoji|
      reaction = Reaction.new(message: @message, user_name: "Alice", emoji: invalid_emoji)
      assert_not reaction.valid?, "Should be invalid with emoji: #{invalid_emoji}"
      assert_includes reaction.errors[:emoji], "is not allowed"
    end
  end

  test "should not save reaction without message" do
    reaction = Reaction.new(message: nil, user_name: "Alice", emoji: "👍")
    assert_not reaction.valid?
    assert_not reaction.save
  end

  test "should not save reaction without user_name" do
    reaction = Reaction.new(message: @message, user_name: nil, emoji: "👍")
    assert_not reaction.valid?
    assert_not reaction.save
  end

  test "should not save reaction without user_name (empty string)" do
    reaction = Reaction.new(message: @message, user_name: "", emoji: "👍")
    assert_not reaction.valid?
    assert_not reaction.save
  end

  test "should enforce unique constraint on message_id, user_name, and emoji combination" do
    existing_reaction = reactions(:one)
    duplicate_reaction = Reaction.new(
      message: existing_reaction.message,
      user_name: existing_reaction.user_name,
      emoji: existing_reaction.emoji
    )
    assert_not duplicate_reaction.valid?
    has_unique_error = duplicate_reaction.errors[:message_id].any? { |msg| msg.include?("already been taken") } ||
                      duplicate_reaction.errors[:user_name].any? { |msg| msg.include?("already been taken") } ||
                      duplicate_reaction.errors[:emoji].any? { |msg| msg.include?("already been taken") }
    assert has_unique_error, "Expected unique constraint error, but got: #{duplicate_reaction.errors.full_messages.join(', ')}"
    assert_not duplicate_reaction.save
  end

  test "should allow same user to react with different emojis on the same message" do
    user_name = "Alice"
    emoji1 = "😮"
    emoji2 = "😢"

    Reaction.create!(message: @message, user_name: user_name, emoji: emoji1)
    second_reaction = Reaction.new(message: @message, user_name: user_name, emoji: emoji2)

    assert second_reaction.valid?, "Should allow same user to react with different emoji"
  end

  test "should allow different users to react with same emoji on the same message" do
    emoji = "😮"

    Reaction.create!(message: @message, user_name: "Dave", emoji: emoji)
    second_reaction = Reaction.new(message: @message, user_name: "Eve", emoji: emoji)

    assert second_reaction.valid?, "Should allow different users to react with same emoji"
  end

  test "should allow same user to react with same emoji on different messages" do
    user_name = "Alice"
    emoji = "😮"

    Reaction.create!(message: @message, user_name: user_name, emoji: emoji)
    second_reaction = Reaction.new(message: @message2, user_name: user_name, emoji: emoji)

    assert second_reaction.valid?, "Should allow same user to react with same emoji on different messages"
  end

  test "should belong to message" do
    reaction = reactions(:one)
    assert_equal messages(:one), reaction.message
  end

  test "should count reactions by emoji" do
    message = messages(:one)
    message.reactions.destroy_all

    Reaction.create!(message: message, user_name: "User1", emoji: "👍")
    Reaction.create!(message: message, user_name: "User2", emoji: "👍")
    Reaction.create!(message: message, user_name: "User3", emoji: "❤️")

    assert_equal 2, message.reactions.where(emoji: "👍").count
    assert_equal 1, message.reactions.where(emoji: "❤️").count
  end
end
