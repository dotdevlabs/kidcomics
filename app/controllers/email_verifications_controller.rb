class EmailVerificationsController < ApplicationController
  skip_before_action :require_login

  def show
    token = params[:token]
    @user = User.find_by(verification_token: token)

    if @user.nil?
      flash[:alert] = "Invalid verification link."
      redirect_to root_path
      return
    end

    if @user.email_verified?
      flash[:notice] = "Your email is already verified. Please log in."
      redirect_to login_path
      return
    end

    if @user.verification_token_expired?
      flash[:alert] = "Verification link has expired. Please request a new one."
      redirect_to root_path
      return
    end

    # Verify the email
    @user.verify_email!

    # Send welcome email if Postmark is configured
    if Setting.postmark_configured?
      begin
        UserMailer.welcome_email(@user).deliver_later
      rescue => e
        Rails.logger.error "Failed to send welcome email: #{e.message}"
      end
    end

    # Log the user in
    reset_session
    session[:user_id] = @user.id

    flash[:notice] = "Email verified successfully! Welcome to KidComics. You can now set your password in your account settings."
    redirect_to dashboard_path
  end
end
