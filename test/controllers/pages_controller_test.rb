require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should render home page" do
    get root_url
    assert_response :success
    assert_select "h1", text: /Bring Your Child's Stories to Life/
  end

  test "should show signup link on home page" do
    get root_url
    assert_response :success
    assert_select "a[href=?]", signup_path
  end

  test "should show login link on home page" do
    get root_url
    assert_response :success
    assert_select "a[href=?]", login_path
  end

  test "should redirect to dashboard if already logged in" do
    user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    user.create_family_account!(name: "Test Family")

    # Simulate login by setting session
    post login_url, params: { email: user.email, password: "password123" }

    get root_url
    assert_redirected_to dashboard_path
  end
end
