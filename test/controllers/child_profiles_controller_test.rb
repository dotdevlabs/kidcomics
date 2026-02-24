require "test_helper"

class ChildProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    @family_account = @user.create_family_account!(name: "Test Family")
    @child_profile = @family_account.child_profiles.create!(name: "Test Child", age: 8)

    # Log in as the user
    post login_url, params: { email: @user.email, password: "password123" }
  end

  test "should get new child profile page" do
    get new_family_account_child_profile_url(@family_account)
    assert_response :success
  end

  test "should create child profile" do
    assert_difference("ChildProfile.count") do
      post family_account_child_profiles_url(@family_account), params: {
        child_profile: { name: "New Child", age: 10 }
      }
    end

    assert_redirected_to dashboard_path
  end

  test "should not create child profile with invalid data" do
    assert_no_difference("ChildProfile.count") do
      post family_account_child_profiles_url(@family_account), params: {
        child_profile: { name: "", age: nil }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should get edit child profile page" do
    get edit_family_account_child_profile_url(@family_account, @child_profile)
    assert_response :success
  end

  test "should update child profile" do
    patch family_account_child_profile_url(@family_account, @child_profile), params: {
      child_profile: { name: "Updated Name", age: 9 }
    }

    assert_redirected_to dashboard_path
    @child_profile.reload
    assert_equal "Updated Name", @child_profile.name
    assert_equal 9, @child_profile.age
  end

  test "should destroy child profile" do
    assert_difference("ChildProfile.count", -1) do
      delete family_account_child_profile_url(@family_account, @child_profile)
    end

    assert_redirected_to dashboard_path
  end

  test "should require login" do
    delete logout_url

    get new_family_account_child_profile_url(@family_account)
    assert_redirected_to login_path
  end
end
