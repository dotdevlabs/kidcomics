require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = User.create!(name: "Admin", email: "admin@test.com", password: "password123", role: :admin)
    @user = User.create!(name: "User", email: "user@test.com", password: "password123", role: :user)
  end

  test "should redirect non-admin users" do
    log_in_as(@user)
    get admin_root_url
    assert_redirected_to root_path
    assert_equal "You must be an administrator to access this page.", flash[:alert]
  end

  test "should allow admin users" do
    log_in_as(@admin)
    get admin_root_url
    assert_response :success
  end

  test "should display dashboard stats" do
    log_in_as(@admin)
    get admin_root_url

    assert_response :success
    assert_select "p", text: "Total Users"
    assert_select "p", text: "Families"
    assert_select "p", text: "Total Books"
    assert_select "p", text: "Pending Moderation"
  end

  private

  def log_in_as(user)
    post login_url, params: { email: user.email, password: "password123" }
  end
end
