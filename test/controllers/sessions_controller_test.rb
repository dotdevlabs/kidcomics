require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @user.create_family_account!(name: "Test Family")
  end

  test "should get login page" do
    get login_url
    assert_response :success
  end

  test "should login with valid credentials" do
    post login_url, params: { email: @user.email, password: "password123" }
    assert_redirected_to dashboard_path
    assert_equal @user.id, session[:user_id]
  end

  test "should not login with invalid credentials" do
    post login_url, params: { email: @user.email, password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should logout" do
    post login_url, params: { email: @user.email, password: "password123" }
    delete logout_url
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end
end
