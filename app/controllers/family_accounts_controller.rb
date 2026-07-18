class FamilyAccountsController < ApplicationController
  before_action :require_login

  def show
    @family_account = current_user.family_account
    unless @family_account
      flash[:alert] = t("flash.family_accounts.not_found")
      redirect_to root_path
    end
  end
end
