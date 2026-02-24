module Admin
  class AuditLogsController < BaseController
    def index
      @admin_actions = AdminAction.includes(:admin_user, :target)
                                  .order(created_at: :desc)
                                  .limit(100)

      # Apply filters
      @admin_actions = @admin_actions.by_admin(params[:admin_id]) if params[:admin_id].present?
      @admin_actions = @admin_actions.by_action_type(params[:action_type]) if params[:action_type].present?

      if params[:date_from].present?
        @admin_actions = @admin_actions.where("created_at >= ?", params[:date_from])
      end

      if params[:date_to].present?
        @admin_actions = @admin_actions.where("created_at <= ?", params[:date_to])
      end

      @admins = User.admins.order(:name)
      @action_types = AdminAction.distinct.pluck(:action_type).sort
    end

    def show
      @admin_action = AdminAction.includes(:admin_user, :target).find(params[:id])
    end
  end
end
