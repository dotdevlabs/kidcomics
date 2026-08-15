module Api
  class ErrorTriggersController < BaseController
    def trigger_not_found
      raise ActiveRecord::RecordNotFound, "Test::Widget"
    end

    def trigger_parameter_missing
      raise ActionController::ParameterMissing, :test_param
    end

    def trigger_server_error
      raise StandardError, "Unexpected boom"
    end
  end
end
