class RegistrationsController < ApplicationController
  def new
    redirect_to dashboard_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      # Create family account for the new user
      family_account = @user.build_family_account(name: family_account_params[:name])

      if family_account.save
        reset_session
        session[:user_id] = @user.id
        flash[:notice] = "Welcome to KidComics, #{@user.name}! Your family account has been created."
        redirect_to dashboard_path
      else
        @user.destroy
        flash.now[:alert] = "Failed to create family account: #{family_account.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Registration failed: #{@user.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def family_account_params
    params.require(:user).permit(:family_name).transform_keys { |key| key == "family_name" ? "name" : key }
  end
end
