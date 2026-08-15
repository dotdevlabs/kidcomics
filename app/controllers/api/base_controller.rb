module Api
  class BaseController < ActionController::API
    rescue_from StandardError,                      with: :render_internal_server_error
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
    rescue_from ActiveRecord::RecordNotFound,       with: :render_not_found

    private

    def render_not_found(exception)
      render_json_api_error(:not_found, "not_found", "Record Not Found", exception.message)
    end

    def render_parameter_missing(exception)
      render_json_api_error(:unprocessable_content, "parameter_missing", "Parameter Missing", exception.message)
    end

    def render_internal_server_error(_exception)
      render_json_api_error(:internal_server_error, "internal_server_error", "Internal Server Error")
    end

    def render_json_api_error(http_status, code, title, detail = nil)
      error = { status: Rack::Utils.status_code(http_status).to_s, code: code, title: title }
      error[:detail] = detail if detail.present?
      render json: { errors: [ error ] },
             status: http_status,
             content_type: "application/vnd.api+json"
    end
  end
end
