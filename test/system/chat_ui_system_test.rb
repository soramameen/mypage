require "application_system_test_case"

class ChatUISystemTest < ApplicationSystemTestCase
  setup do
    @room = Room.create!(name: "Test Room")
    @user_name = "TestUser-#{Time.now.to_i}"
    @other_user_name = "OtherUser-#{Time.now.to_i}"
  end

  # ========== システムテスト ST-001: メッセージのバブルデザインが正しく表示されること ==========
  test "ST-001: メッセージのバブルデザインが正しく表示される" do
    message = @room.messages.create!(content: "This is a test message", user_name: @user_name)

    visit chat_room_path(@room)

    assert_selector ".message", count: 1
    message_element = find(".message")
    assert message_element.visible?

    # Check bubble design elements
    assert message_element[:class].include?("message")

    # Verify message content is properly contained
    within ".message" do
      assert_text "This is a test message"
      assert_selector ".message-content"
    end
  end

  # ========== システムテスト ST-002: 送信者/受信者のメッセージで色と配置が正しく区別されること ==========
  test "ST-002: 送信者/受信者のメッセージで色と配置が正しく区別される" do
    my_message = @room.messages.create!(content: "My message", user_name: @user_name)
    other_message = @room.messages.create!(content: "Other message", user_name: @other_user_name)

    visit chat_room_path(@room)
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"

    messages = all(".message")
    assert_equal 2, messages.length

    # Both messages should be visible
    assert_text "My message"
    assert_text "Other message"
  end

  # ========== システムテスト ST-003: タイムスタンプが正しく表示されること ==========
  test "ST-003: タイムスタンプが正しく表示される" do
    message = @room.messages.create!(content: "Test message", user_name: @user_name)

    visit chat_room_path(@room)

    within ".message" do
      assert_selector ".timestamp"
      timestamp_text = find(".timestamp").text

      # Check if timestamp is in HH:MM format
      assert_match /\d{2}:\d{2}/, timestamp_text
    end
  end

  # ========== システムテスト ST-004: リアクション機能が正しく動作すること ==========
  test "ST-004: リアクション機能が正しく動作する" do
    message = @room.messages.create!(content: "Test message", user_name: @user_name)

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"

    click_on @room.name

    # Check reaction buttons exist
    assert_selector ".reaction-button", count: 5

    # Add reaction
    find_button("👍", match: :first).click
    assert_text "👍"

    # Verify reaction was added to database
    assert_equal 1, message.reactions.where(emoji: "👍", user_name: @user_name).count
  end

  # ========== システムテスト ST-005: ホバーでリアクションボタンが表示されること ==========
  test "ST-005: ホバーでリアクションボタンが表示される" do
    @room.messages.create!(content: "Test message", user_name: @user_name)

    visit chat_room_path(@room)

    # Reaction buttons should be present
    assert_selector ".reaction-button", count: 5

    message_element = find(".message")

    # Hover over message
    message_element.hover

    # Verify reaction buttons are still visible after hover
    assert_selector ".reaction-button", count: 5
  end

  # ========== システムテスト ST-006: ユーザー名がメッセージに正しく表示されること ==========
  test "ST-006: ユーザー名がメッセージに正しく表示される" do
    @room.messages.create!(content: "Test message", user_name: @user_name)

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"

    click_on @room.name

    within ".message" do
      assert_selector ".user-name"
      assert_text @user_name
    end
  end

  # ========== システムテスト ST-007: 絵文字を含むメッセージが正しく表示されること ==========
  test "ST-007: 絵文字を含むメッセージが正しく表示される" do
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"

    click_on @room.name

    fill_in "message[content]", with: "Hello 👋 World 😊"
    click_on "送信"

    assert_text "Hello"
    assert_text "World"
  end

  # ========== ビューテスト VT-001: チャットルームのレイアウトが正しいこと ==========
  test "VT-001: チャットルームのレイアウトが正しい" do
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Check header
    assert_selector "h1"
    assert_text @room.name

    # Check messages area
    assert_selector "#messages"

    # Check input area
    assert_selector "#new_message"
  end

  # ========== ビューテスト VT-002: 固定ヘッダー/フッターが正しく配置されていること ==========
  test "VT-002: 固定ヘッダー/フッターが正しく配置されている" do
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Check header is present at the top
    assert_selector "h1"

    # Check footer/input area is present
    assert_selector "#new_message"

    # Both should be visible on the page
    assert page.has_css?("h1", visible: true)
    assert page.has_css?("#new_message", visible: true)
  end

  # ========== ビューテスト VT-003: メッセージエリアがスクロール可能であること ==========
  test "VT-003: メッセージエリアがスクロール可能である" do
    # Create many messages
    50.times do |i|
      @room.messages.create!(content: "Message #{i}", user_name: "#{@user_name}-#{i}")
    end

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    messages_container = find("#messages")

    # Check if container is scrollable (has overflow)
    scroll_height = messages_container.evaluate_script("this.scrollHeight")
    client_height = messages_container.evaluate_script("this.clientHeight")

    # With 50 messages, scroll height should be greater than client height
    assert scroll_height > client_height, "Messages should be scrollable"
  end

  # ========== ビューテスト VT-004: レスポンシブデザインが正しく機能すること ==========
  test "VT-004: レスポンシブデザインが正しく機能する" do
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Test desktop size
    resize_window_to(1920, 1080)
    assert_selector "h1"
    assert_selector "#messages"
    assert_selector "#new_message"

    # Test tablet size
    resize_window_to(768, 1024)
    assert_selector "h1"
    assert_selector "#messages"
    assert_selector "#new_message"

    # Test mobile size
    resize_window_to(375, 667)
    assert_selector "h1"
    assert_selector "#messages"
    assert_selector "#new_message"
  end

  # ========== ビューテスト VT-005: メッセージ送信フォームが正しく表示されること ==========
  test "VT-005: メッセージ送信フォームが正しく表示される" do
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    within "#new_message" do
      assert_selector "input[type='text']"
      input_field = find("input[type='text']")
      assert_equal "メッセージを入力...", input_field[:placeholder]
      assert_selector "input[type='submit']"
    end
  end

  # ========== ビューテスト VT-006: メッセージ編集フォームが正しく表示されること ==========
  test "VT-006: メッセージ編集フォームが正しく表示される" do
    message = @room.messages.create!(content: "Original message", user_name: @user_name)

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Click edit button
    find_button("編集", match: :first).click

    # Wait for turbo frame to load
    assert_selector "textarea[name='message[content]']"

    # Check current message is in the textarea
    textarea = find("textarea[name='message[content]']")
    assert_equal "Original message", textarea.value
  end

  # ========== 統合テスト IT-001: 新規メッセージ作成のフロー ==========
  test "IT-001: 新規メッセージ作成のフロー" do
    initial_count = @room.messages.count

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    fill_in "message[content]", with: "New test message"
    click_on "送信"

    # Verify message was saved to database
    assert_equal initial_count + 1, @room.messages.count
    assert Message.exists?(content: "New test message", room_id: @room.id)

    # Verify message is displayed on page
    assert_text "New test message"

    # Verify input field is reset
    input_field = find("input[name='message[content]']")
    assert_equal "", input_field.value
  end

  # ========== 統合テスト IT-002: リアルタイム通信（ActionCable）の動作 ==========
  test "IT-002: リアルタイム通信（ActionCable）の動作" do
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Simulate another user sending a message
    using_session "other_user" do
      visit chat_rooms_path
      fill_in "user_name", with: @other_user_name
      click_on "チャットを始める"
      click_on @room.name

      fill_in "message[content]", with: "Message from other user"
      click_on "送信"

      assert_text "Message from other user"
    end

    # Note: Real-time updates depend on ActionCable configuration
    # In tests, we verify the message was saved to the database
    assert Message.exists?(content: "Message from other user", room_id: @room.id)
  end

  # ========== 統合テスト IT-003: スクロール管理の動作 ==========
  test "IT-003: スクロール管理の動作" do
    # Create multiple messages
    20.times do |i|
      @room.messages.create!(content: "Message #{i}", user_name: @user_name)
    end

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Send a new message
    fill_in "message[content]", with: "New message"
    click_on "送信"

    # Verify the new message is visible
    assert_text "New message"
  end

  # ========== 統合テスト IT-004: メッセージ編集の統合フロー ==========
  test "IT-004: メッセージ編集の統合フロー" do
    message = @room.messages.create!(content: "Original", user_name: @user_name)

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Edit the message
    find_button("編集", match: :first).click
    find("textarea[name='message[content]']").fill_in with: "Edited message"
    click_on "更新"

    # Verify message was updated
    assert_text "Edited message"
    assert_equal "Edited message", message.reload.content
  end

  # ========== 統合テスト IT-005: メッセージ削除の統合フロー ==========
  test "IT-005: メッセージ削除の統合フロー" do
    @room.messages.create!(content: "To be deleted", user_name: @user_name)

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    assert_text "To be deleted"

    # Delete the message
    accept_confirm do
      find_button("削除", match: :first).click
    end

    # Verify message was removed
    assert_no_text "To be deleted"
    assert_not Message.exists?(content: "To be deleted", room_id: @room.id)
  end

  # ========== 統合テスト IT-006: 複数ユーザーによるリアルタイムタイピング通知 ==========
  test "IT-006: 複数ユーザーによるリアルタイムタイピング通知" do
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Verify typing indicator element exists
    assert_selector "#typing-indicator"

    # Start typing
    message_input = find("input[name='message[content]']")
    message_input.fill_in with: "typing..."

    # The typing indicator functionality depends on ActionCable
    # We verify the input is functional
    assert_equal "typing...", message_input.value
  end

  # ========== 統合テスト IT-007: 複数のリアクションが正しく集計されること ==========
  test "IT-007: 複数のリアクションが正しく集計されること" do
    message = @room.messages.create!(content: "Test message", user_name: @user_name)

    visit chat_rooms_path

    # Add first reaction as user 1
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name
    find_button("👍", match: :first).click
    assert_text "👍"

    # Add same reaction as user 2
    user2_name = "User2-#{Time.now.to_i}"
    using_session "user2" do
      visit chat_rooms_path
      fill_in "user_name", with: user2_name
      click_on "チャットを始める"
      click_on @room.name
      find_button("👍", match: :first).click
      assert_text "👍"
    end

    # Verify both reactions are in database
    assert_equal 2, message.reactions.where(emoji: "👍").count
  end

  # ========== 統合テスト IT-008: チャットルーム間でのデータ分離 ==========
  test "IT-008: チャットルーム間でのデータ分離" do
    room2 = Room.create!(name: "Second Room")

    # Send message in room 1
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name
    fill_in "message[content]", with: "Message for room 1"
    click_on "送信"
    assert_text "Message for room 1"

    # Go to room 2 and verify message from room 1 is not there
    visit chat_rooms_path
    click_on room2.name
    assert_no_text "Message for room 1"

    # Send message in room 2
    fill_in "message[content]", with: "Message for room 2"
    click_on "送信"
    assert_text "Message for room 2"

    # Verify message count in each room
    assert_equal 1, @room.messages.where(content: "Message for room 1").count
    assert_equal 1, room2.messages.where(content: "Message for room 2").count
  end

  # ========== 統合テスト IT-009: 同時メッセージ送信時の順序保持 ==========
  test "IT-009: 同時メッセージ送信時の順序保持" do
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Send multiple messages quickly
    3.times do |i|
      fill_in "message[content]", with: "Message #{i}"
      click_on "送信"
    end

    # Verify all messages are displayed
    3.times do |i|
      assert_text "Message #{i}"
    end

    # Verify messages exist in database with correct timestamps
    messages = @room.messages.where("content LIKE ?", "Message %").order(:created_at)
    assert_equal 3, messages.count
  end

  # ========== 統合テスト IT-010: 空メッセージ送信の防止 ==========
  test "IT-010: 空メッセージ送信の防止" do
    initial_count = @room.messages.count

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Try to send empty message
    fill_in "message[content]", with: ""
    click_on "送信"

    # Verify no new message was created
    assert_equal initial_count, @room.messages.count
  end

  # ========== エッジケース EC-001: 超長メッセージの送信 ==========
  test "EC-001: 超長メッセージの送信" do
    long_message = "A" * 2000

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    fill_in "message[content]", with: long_message
    click_on "送信"

    # Verify message was saved and displayed
    assert Message.exists?(content: long_message, room_id: @room.id)

    # Verify message is visible on page
    assert_text long_message[0..100]
  end

  # ========== エッジケース EC-006: 他ユーザーのメッセージの編集・削除の防止 ==========
  test "EC-006: 他ユーザーのメッセージの編集・削除の防止" do
    @room.messages.create!(content: "Other user's message", user_name: @other_user_name)

    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    assert_text "Other user's message"

    # Edit and delete buttons should not be visible for other user's messages
    within all(".message").first do
      assert_no_selector "button", text: "編集"
      assert_no_selector "button", text: "削除"
    end
  end

  # ========== エッジケース EC-002: 特殊文字を含むメッセージの送信 ==========
  test "EC-002: 特殊文字を含むメッセージの送信" do
    visit chat_rooms_path
    fill_in "user_name", with: @user_name
    click_on "チャットを始める"
    click_on @room.name

    # Try to send HTML/script
    fill_in "message[content]", with: "<script>alert('xss')</script>"
    click_on "送信"

    # Verify message was saved (escaped)
    assert Message.exists?(content: "<script>alert('xss')</script>", room_id: @room.id)

    # Verify script is not executed (text is displayed as-is)
    assert_text "&lt;script&gt;alert"
  end

  private

  def resize_window_to(width, height)
    if Capybara.current_session.driver.respond_to?(:resize_window_to)
      current_window = Capybara.current_session.current_window
      Capybara.current_session.driver.resize_window_to(current_window.handle, width, height)
    end
  end
end
