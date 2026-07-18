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
      flash.now[:alert] = t("flash.sessions.not_found")
      render :new, status: :unprocessable_entity
      return
    end

    # If user has incomplete onboarding, redirect to nopassword magic link flow
    if user.needs_magic_link_login?
      redirect_to new_email_authentication_path(nopassword_email_authentication: { email: email }), notice: t("flash.sessions.incomplete_registration")
      return
    end

    # Normal password authentication for users with completed onboarding
    if user.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      flash[:notice] = t("flash.sessions.welcome_back", name: user.name)
      redirect_to dashboard_path
    else
      flash.now[:alert] = t("flash.sessions.invalid_password")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    flash[:notice] = t("flash.sessions.logged_out")
    redirect_to login_path
  end
end
