class MagicLinksController < ApplicationController
  skip_before_action :require_login

  # GET /magic_link/:token - Validate token and log user in
  def show
    token = params[:token]
    user = User.find_by(login_token: token)

    if user && user.login_token_valid?(token)
      # Clear the token (single use)
      user.clear_login_token!

      # Log the user in
      reset_session
      session[:user_id] = user.id

      # If they're in onboarding, continue from where they left off
      if user.onboarding_in_progress?
        session[:onboarding_user_id] = user.id

        # Determine where to redirect based on onboarding progress
        if user.family_account.blank?
          redirect_to onboarding_name_path, notice: "Welcome back! Let's continue your registration."
        elsif user.family_account.child_profiles.empty?
          redirect_to onboarding_child_profile_path, notice: "Welcome back! Let's continue your registration."
        else
          # They have a child profile, check if they have books
          if user.family_account.child_profiles.joins(:books).exists?
            redirect_to dashboard_path, notice: "Welcome back! Complete your first book to finish onboarding."
          else
            redirect_to dashboard_path, notice: "Welcome back! Create your first book to get started."
          end
        end
      else
        redirect_to dashboard_path, notice: "Welcome back, #{user.name}!"
      end
    else
      redirect_to login_path, alert: "This magic link is invalid or has expired. Please request a new one."
    end
  end

  # POST /magic_link - Generate and send magic link
  def create
    email = params[:email]&.strip&.downcase

    if email.blank?
      redirect_to login_path, alert: "Please enter an email address"
      return
    end

    user = User.find_by(email: email)

    if user.blank?
      # User doesn't exist - redirect to signup
      redirect_to signup_path, alert: "No account found with that email. Please sign up."
      return
    end

    # Generate login token
    token = user.generate_login_token

    # In development mode, just log them in directly
    if Rails.env.development?
      redirect_to magic_link_url(token), notice: "Development mode: Auto-logging you in..."
    else
      # In production, send email with magic link
      UserMailer.magic_link_email(user, token).deliver_later
      redirect_to login_path, notice: "Check your email! We've sent you a link to log in."
    end
  end
end
