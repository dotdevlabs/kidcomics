class ApplicationController < ActionController::Base
  include AdminAuthorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  around_action :switch_locale
  before_action :require_login

  helper_method :current_user, :logged_in?, :current_child_profile

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def current_child_profile
    @current_child_profile ||= ChildProfile.find_by(id: session[:child_profile_id]) if session[:child_profile_id]
  end

  def require_login
    unless logged_in?
      flash[:alert] = t("flash.application.require_login")
      redirect_to login_path
    end
  end

  def require_family_owner
    unless logged_in? && current_user.family_account.present?
      flash[:alert] = t("flash.application.require_family_owner")
      redirect_to login_path
    end
  end

  def switch_locale(&action)
    I18n.with_locale(resolve_locale, &action)
  end

  def resolve_locale
    if params[:locale].present?
      requested = params[:locale].to_sym
      if I18n.available_locales.include?(requested)
        current_user&.update_column(:locale, requested.to_s)
        return requested
      end
    end

    if current_user&.locale.present?
      locale = current_user.locale.to_sym
      return locale if I18n.available_locales.include?(locale)
    end

    locale_from_accept_language || I18n.default_locale
  end

  def locale_from_accept_language
    available = I18n.available_locales.map(&:to_s)
    request.env.fetch("HTTP_ACCEPT_LANGUAGE", "")
      .split(",")
      .map { |l| l.split(";").first.strip }
      .find { |l| available.include?(l) }
      &.to_sym
  end
end
