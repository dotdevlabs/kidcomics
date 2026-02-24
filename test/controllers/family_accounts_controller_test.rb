require "test_helper"

class FamilyAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = @user.create_family_account!(name: "Test Family")

    # Log in as the user
    post login_url, params: { email: @user.email, password: "password123" }
  end

  test "should get family dashboard" do
    get dashboard_url
    assert_response :success
  end

  test "should require login" do
    delete logout_url
    get dashboard_url
    assert_redirected_to login_path
  end
end
