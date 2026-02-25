module Admin
  class SettingsController < BaseController
    def index
      @postmark_api_key = Setting.get("postmark_api_key", "")
      @postmark_from_email = Setting.get("postmark_from_email", "noreply@kidcomics.app")
      @postmark_configured = Setting.postmark_configured?
    end

    def update
      setting_key = params[:setting_key]
      setting_value = params[:setting_value]

      case setting_key
      when "postmark_api_key"
        Setting.set("postmark_api_key", setting_value, description: "Postmark API Key for transactional emails")
        flash[:notice] = "Postmark API key updated successfully"
      when "postmark_from_email"
        Setting.set("postmark_from_email", setting_value, description: "From email address for outgoing emails")
        flash[:notice] = "From email address updated successfully"
      else
        flash[:alert] = "Invalid setting"
      end

      redirect_to admin_settings_path
    end
  end
end
