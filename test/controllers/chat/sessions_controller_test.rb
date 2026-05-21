require "test_helper"

class Chat::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should set user name in session" do
    post chat_set_name_path, params: { user_name: "Alice" }
    assert_redirected_to chat_rooms_path
    assert_equal "Alice", session[:user_name]
  end

  test "should redirect to chat_rooms_path after setting name" do
    post chat_set_name_path, params: { user_name: "TestUser" }
    assert_redirected_to chat_rooms_path
  end

  test "should set empty name in session when provided" do
    post chat_set_name_path, params: { user_name: "" }
    assert_equal "", session[:user_name]
    assert_redirected_to chat_rooms_path
  end

  test "should set nil name in session when not provided" do
    post chat_set_name_path, params: {}
    assert_nil session[:user_name]
    assert_redirected_to chat_rooms_path
  end

  test "should handle unicode names correctly" do
    post chat_set_name_path, params: { user_name: "🎉テストユーザー" }
    assert_equal "🎉テストユーザー", session[:user_name]
  end

  test "should handle very long names" do
    long_name = "a" * 1000
    post chat_set_name_path, params: { user_name: long_name }
    assert_equal long_name, session[:user_name]
  end

  test "should update existing session user name" do
    post chat_set_name_path, params: { user_name: "FirstUser" }
    assert_equal "FirstUser", session[:user_name]

    post chat_set_name_path, params: { user_name: "SecondUser" }
    assert_equal "SecondUser", session[:user_name]
  end

  test "should respond with redirect status" do
    post chat_set_name_path, params: { user_name: "TestUser" }
    assert_response :redirect
  end

  test "should handle JSON format" do
    post chat_set_name_path, params: { user_name: "JsonUser" }, as: :json
    assert_response :redirect
  end

  test "should handle turbo_stream format" do
    post chat_set_name_path, params: { user_name: "TurboUser" }, as: :turbo_stream
    assert_response :redirect
  end
end
