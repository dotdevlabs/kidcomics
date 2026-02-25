class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    redirect_to dashboard_path if logged_in?
  end

  def create
    email = params[:email]&.downcase
    user = User.find_by(email: email)

    # If no user found
    if user.blank?
      flash.now[:alert] = "No account found with that email"
      render :new, status: :unprocessable_entity
      return
    end

    # If user has incomplete onboarding, use magic link flow
    if user.needs_magic_link_login?
      # Generate login token
      token = user.generate_login_token

      # In development mode, just log them in directly
      if Rails.env.development?
        redirect_to magic_link_path(token), notice: "Development mode: Logging you in..."
      else
        # In production, send email with magic link
        UserMailer.magic_link_email(user, token).deliver_later
        redirect_to login_path, notice: "Check your email! We've sent you a link to continue your registration."
      end
      return
    end

    # Normal password authentication for users with completed onboarding
    if user.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      flash[:notice] = "Welcome back, #{user.name}!"
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to login_path
  end
end
