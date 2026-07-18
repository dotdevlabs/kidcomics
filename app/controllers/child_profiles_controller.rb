class ChildProfilesController < ApplicationController
  before_action :require_family_owner
  before_action :set_family_account
  before_action :set_child_profile, only: [ :edit, :update, :destroy ]

  def index
    @child_profiles = @family_account.child_profiles
  end

  def new
    @child_profile = @family_account.child_profiles.build
  end

  def create
    @child_profile = @family_account.child_profiles.build(child_profile_params)

    if @child_profile.save
      flash[:notice] = t("flash.child_profiles.created")
      redirect_to dashboard_path
    else
      flash.now[:alert] = t("flash.child_profiles.create_failed", errors: @child_profile.errors.full_messages.join(", "))
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @child_profile.update(child_profile_params)
      flash[:notice] = t("flash.child_profiles.updated")
      redirect_to dashboard_path
    else
      flash.now[:alert] = t("flash.child_profiles.update_failed", errors: @child_profile.errors.full_messages.join(", "))
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @child_profile.destroy
    flash[:notice] = t("flash.child_profiles.deleted")
    redirect_to dashboard_path
  end

  private

  def set_family_account
    @family_account = current_user.family_account
    unless @family_account
      flash[:alert] = t("flash.child_profiles.no_family_account")
      redirect_to root_path
    end
  end

  def set_child_profile
    @child_profile = @family_account.child_profiles.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t("flash.child_profiles.not_found")
    redirect_to dashboard_path
  end

  def child_profile_params
    params.require(:child_profile).permit(:name, :age, :avatar)
  end
end
