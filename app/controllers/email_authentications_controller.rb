class EmailAuthenticationsController < NoPassword::EmailAuthenticationsController
  skip_before_action :require_login

  # Called when the user successfully verifies their email via the magic link
  def verification_succeeded(email)
    user = User.find_by(email: email)

    if user.blank?
      # User doesn't exist - redirect to signup
      flash[:alert] = "No account found with that email. Please sign up."
      redirect_to signup_path
      return
    end

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
  end

  # Customize how the email is sent
  def deliver_challenge(challenge)
    user = User.find_by(email: challenge.email)

    # If no user exists, let the normal flow handle it
    return unless user

    # In development mode, automatically redirect to the magic link
    # Store the token in the session so we can redirect after the create action completes
    if Rails.env.development?
      session[:dev_magic_link_token] = challenge.token
    else
      # In production, send email with magic link
      UserMailer.magic_link_email(user, email_authentication_url(challenge.token)).deliver_later
    end
  end

  # Override the success page to auto-redirect in development
  def create
    super

    # In development mode, auto-redirect to the verification link
    if Rails.env.development? && session[:dev_magic_link_token]
      token = session.delete(:dev_magic_link_token)
      flash[:notice] = "Development mode: Auto-logging you in..."
      redirect_to email_authentication_path(token)
    end
  end
end
