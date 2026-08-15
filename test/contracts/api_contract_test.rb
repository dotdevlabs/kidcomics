require "test_helper"
require "yaml"
require "support/api/error_triggers_controller"

class ApiContractTest < ActionDispatch::IntegrationTest
  SPEC = YAML.safe_load_file(Rails.root.join("docs", "api_spec.yaml"))
  JSONAPI_CONTENT_TYPE = "application/vnd.api+json"
  HTTP_METHODS = %w[get post put patch delete head options].freeze

  # -------------------------------------------------------------------
  # CODE->SPEC: every Api:: route must be documented in the spec
  # -------------------------------------------------------------------
  test "every Api:: route is documented in the spec" do
    spec_paths = SPEC.fetch("paths", {})

    api_routes.each do |route|
      path = normalized_path(route)
      verb = route.verb.downcase
      assert spec_paths.key?(path),
             "Route #{verb.upcase} #{path} (controller: #{route.defaults[:controller]}) is not documented in docs/api_spec.yaml"
      assert spec_paths[path].key?(verb),
             "Route #{verb.upcase} #{path} is missing a '#{verb}' operation in docs/api_spec.yaml"
    end
  end

  # -------------------------------------------------------------------
  # SPEC->CODE: every spec path+operation must resolve to a real route
  # -------------------------------------------------------------------
  test "every spec path resolves to a real route" do
    SPEC.fetch("paths", {}).each do |path, operations|
      operations.each do |method, _operation|
        next unless HTTP_METHODS.include?(method.downcase)
        begin
          resolved = Rails.application.routes.recognize_path(path, method: method.upcase)
          assert resolved,
                 "Spec path #{method.upcase} #{path} does not match any route in the app"
        rescue ActionController::RoutingError => e
          flunk "Spec path #{method.upcase} #{path} does not match any route: #{e.message}"
        end
      end
    end
  end

  # -------------------------------------------------------------------
  # Per-endpoint compliance: GET /status
  # -------------------------------------------------------------------
  test "GET /status returns 200 with application/vnd.api+json content type" do
    get "/status"
    assert_response :ok
    assert_equal JSONAPI_CONTENT_TYPE, response.media_type
  end

  test "GET /status body has JSON:API envelope with correct type and id" do
    get "/status"
    body = JSON.parse(response.body)
    assert body.key?("data"), "Response body must have a 'data' key"
    assert_equal "status",  body.dig("data", "type")
    assert_equal "current", body.dig("data", "id")
  end

  test "GET /status attributes contain only documented fields" do
    attr_schema = SPEC.dig("components", "schemas", "StatusAttributes")
    documented_keys = attr_schema["properties"].keys

    get "/status"
    attrs = JSON.parse(response.body).dig("data", "attributes")
    assert_kind_of Hash, attrs

    undocumented = attrs.keys - documented_keys
    assert undocumented.empty?,
           "Response has undocumented attributes: #{undocumented.inspect}. Add them to docs/api_spec.yaml."
  end

  test "GET /status version attribute is a string or null" do
    get "/status"
    value = JSON.parse(response.body).dig("data", "attributes", "version")
    assert(value.nil? || value.is_a?(String), "version must be String or null, got #{value.class}")
  end

  test "GET /status sha attribute is a string or null" do
    get "/status"
    value = JSON.parse(response.body).dig("data", "attributes", "sha")
    assert(value.nil? || value.is_a?(String), "sha must be String or null, got #{value.class}")
  end

  test "GET /status db_version attribute is a string or null" do
    get "/status"
    value = JSON.parse(response.body).dig("data", "attributes", "db_version")
    assert(value.nil? || value.is_a?(String), "db_version must be String or null, got #{value.class}")
  end

  # -------------------------------------------------------------------
  # Error format conformance: error responses must match JsonApiErrors schema
  # -------------------------------------------------------------------
  test "error responses match the JsonApiErrors schema in the spec" do
    error_schema = SPEC.dig("components", "schemas", "JsonApiError")
    required_keys = error_schema.fetch("required", [])

    Rails.application.routes.draw do
      get "/api/contract_test/not_found", to: "api/error_triggers#trigger_not_found"
    end

    begin
      get "/api/contract_test/not_found"
      body = JSON.parse(response.body)
      assert body.key?("errors"), "Error response must have top-level 'errors' key per JsonApiErrors schema"
      assert_kind_of Array, body["errors"]

      error_object = body["errors"].first
      assert_kind_of Hash, error_object

      required_keys.each do |key|
        assert error_object.key?(key),
               "Error object is missing required field '#{key}' defined in JsonApiError schema"
      end
    ensure
      Rails.application.reload_routes!
    end
  end

  private

  def api_routes
    Rails.application.routes.routes.select do |route|
      route.defaults[:controller].to_s.start_with?("api/")
    end
  end

  def normalized_path(route)
    route.path.spec.to_s.gsub(/\(\.:[^)]+\)/, "")
  end

  def resolve_ref(ref_string)
    return {} if ref_string.nil?
    parts = ref_string.delete_prefix("#/").split("/")
    parts.reduce(SPEC) { |node, key| node.fetch(key) }
  end
end
