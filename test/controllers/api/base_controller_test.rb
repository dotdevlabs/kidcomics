require "test_helper"
require "support/api/error_triggers_controller"

class Api::BaseControllerTest < ActionDispatch::IntegrationTest
  JSONAPI_CONTENT_TYPE = "application/vnd.api+json"

  setup do
    Rails.application.routes.draw do
      get "/api/test/not_found",         to: "api/error_triggers#trigger_not_found"
      get "/api/test/parameter_missing", to: "api/error_triggers#trigger_parameter_missing"
      get "/api/test/server_error",      to: "api/error_triggers#trigger_server_error"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  # --- RecordNotFound → 404 ---
  test "RecordNotFound returns 404 with JSON:API content type" do
    get "/api/test/not_found"
    assert_response :not_found
    assert_equal JSONAPI_CONTENT_TYPE, response.media_type
  end

  test "RecordNotFound body has errors array with status 404" do
    get "/api/test/not_found"
    body = JSON.parse(response.body)
    assert body.key?("errors"), "Response must have top-level 'errors' key"
    assert_kind_of Array, body["errors"]
    assert_equal "404", body.dig("errors", 0, "status")
    assert body.dig("errors", 0, "title").present?
  end

  # --- ParameterMissing → 422 ---
  test "ParameterMissing returns 422 with JSON:API content type" do
    get "/api/test/parameter_missing"
    assert_response :unprocessable_entity
    assert_equal JSONAPI_CONTENT_TYPE, response.media_type
  end

  test "ParameterMissing body has errors array with status 422" do
    get "/api/test/parameter_missing"
    body = JSON.parse(response.body)
    assert body.key?("errors")
    assert_kind_of Array, body["errors"]
    assert_equal "422", body.dig("errors", 0, "status")
  end

  # --- StandardError → 500 ---
  test "unhandled StandardError returns 500 with JSON:API content type" do
    get "/api/test/server_error"
    assert_response :internal_server_error
    assert_equal JSONAPI_CONTENT_TYPE, response.media_type
  end

  test "unhandled StandardError body has errors array with status 500" do
    get "/api/test/server_error"
    body = JSON.parse(response.body)
    assert body.key?("errors")
    assert_kind_of Array, body["errors"]
    assert_equal "500", body.dig("errors", 0, "status")
    refute body.dig("errors", 0, "detail")&.include?("Unexpected boom"),
           "Server error detail must not expose internal exception message"
  end
end
