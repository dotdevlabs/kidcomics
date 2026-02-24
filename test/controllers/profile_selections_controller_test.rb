require "test_helper"

class ProfileSelectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = @user.create_family_account!(name: "Test Family")
    @child_profile = @family_account.child_profiles.create!(name: "Test Child", age: 8)

    # Log in as the user
    post login_url, params: { email: @user.email, password: "password123" }
  end

  test "should get profile selection page" do
    get select_profile_url
    assert_response :success
  end

  test "should select a child profile" do
    post create_profile_selection_url(@child_profile)
    assert_redirected_to root_path
    assert_equal @child_profile.id, session[:child_profile_id]
  end
end
