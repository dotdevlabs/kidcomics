require "test_helper"

# GET /status is fully covered by test/contracts/api_contract_test.rb.
# Tests here add coverage for edge cases not tested at the contract level.
class Api::StatusControllerTest < ActionDispatch::IntegrationTest
  test "GET /status responds successfully" do
    get "/status"
    assert_response :ok
  end

  test "GET /status returns JSON:API content type" do
    get "/status"
    assert_equal "application/vnd.api+json", response.media_type
  end
end
