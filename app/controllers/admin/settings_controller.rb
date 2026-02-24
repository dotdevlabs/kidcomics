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

    def test_email
      unless Setting.postmark_configured?
        flash[:alert] = "Please configure Postmark API key first"
        redirect_to admin_settings_path
        return
      end

      # Create a test user object
      test_user = OpenStruct.new(
        name: current_user.name,
        email: current_user.email,
        verification_token: SecureRandom.urlsafe_base64(32)
      )

      begin
        UserMailer.verification_email(test_user).deliver_now
        flash[:notice] = "Test email sent successfully to #{current_user.email}"
      rescue => e
        flash[:alert] = "Failed to send test email: #{e.message}"
      end

      redirect_to admin_settings_path
    end
  end
end
