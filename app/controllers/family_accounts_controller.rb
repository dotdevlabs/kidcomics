class FamilyAccountsController < ApplicationController
  before_action :require_login

  def show
    @family_account = current_user.family_account
    unless @family_account
      flash[:alert] = "You don't have a family account yet."
      redirect_to root_path
    end
  end
end
