require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get signup page" do
    get signup_url
    assert_response :success
  end

  test "should create user and family account" do
    assert_difference([ "User.count", "FamilyAccount.count" ], 1) do
      post signup_url, params: {
        user: {
          name: "New User",
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          family_name: "New Family"
        }
      }
    end

    assert_redirected_to dashboard_path
    assert_not_nil session[:user_id]
  end

  test "should not create user with invalid data" do
    assert_no_difference([ "User.count", "FamilyAccount.count" ]) do
      post signup_url, params: {
        user: {
          name: "",
          email: "invalid",
          password: "short",
          password_confirmation: "short",
          family_name: "New Family"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
