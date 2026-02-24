module Admin
  class BaseController < ApplicationController
    before_action :require_admin
    layout "admin"

    private

    def log_admin_action(action_type, target = nil, details = {})
      AdminAction.log(
        admin: current_user,
        action: action_type,
        target: target,
        details: details,
        ip: request.remote_ip
      )
    end
  end
end
