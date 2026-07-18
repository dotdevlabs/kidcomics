module AdminAuthorization
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_admin?
  end

  private

  def require_admin
    unless logged_in? && current_user.admin?
      # Log unauthorized access attempt
      Rails.logger.warn("Unauthorized admin access attempt by user #{current_user&.id || 'unknown'} from IP #{request.remote_ip}")

      flash[:alert] = t("flash.admin.authorization.not_admin")
      redirect_to root_path
    end
  end

  def current_user_admin?
    logged_in? && current_user.admin?
  end
end
