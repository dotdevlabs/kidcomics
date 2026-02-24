class ApplicationController < ActionController::Base
  include AdminAuthorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

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
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end

  def require_family_owner
    unless logged_in? && current_user.family_account.present?
      flash[:alert] = "You must be a family account owner to access this page."
      redirect_to login_path
    end
  end
end
