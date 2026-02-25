module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :update ]

    def index
      @users = User.includes(:family_account)
                   .order(created_at: :desc)
                   .limit(100)

      # Apply filters
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.where("email ILIKE ? OR name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
      @users = @users.where("created_at >= ?", params[:created_after]) if params[:created_after].present?
    end

    def show
      @family_account = @user.family_account
      @child_profiles = @family_account&.child_profiles || []
      @books = Book.joins(child_profile: :family_account)
                   .where(family_accounts: { owner_id: @user.id })
                   .order(created_at: :desc)
                   .limit(10)
      @admin_actions = AdminAction.where(target: @user).recent.limit(10)
    end

    def update
      old_role = @user.role

      if @user.update(user_params)
        if old_role != @user.role
          log_admin_action(
            "user_role_changed",
            @user,
            { old_role: old_role, new_role: @user.role }
          )
        else
          log_admin_action("user_updated", @user)
        end

        flash[:notice] = "User updated successfully."
        redirect_to admin_user_path(@user)
      else
        flash.now[:alert] = "Failed to update user: #{@user.errors.full_messages.join(', ')}"
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email)
    end
  end
end
