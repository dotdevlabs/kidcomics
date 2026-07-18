class ProfileSelectionsController < ApplicationController
  before_action :require_login

  def index
    @family_account = current_user.family_account
    unless @family_account
      flash[:alert] = t("flash.profile_selections.no_family_account")
      redirect_to dashboard_path
      return
    end
    @child_profiles = @family_account.child_profiles
  end

  def create
    child_profile = current_user.family_account.child_profiles.find_by(id: params[:id])

    if child_profile
      session[:child_profile_id] = child_profile.id
      flash[:notice] = t("flash.profile_selections.welcome", name: child_profile.name)
      redirect_to root_path
    else
      flash[:alert] = t("flash.profile_selections.not_found")
      redirect_to select_profile_path
    end
  end
end
