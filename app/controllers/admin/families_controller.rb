module Admin
  class FamiliesController < BaseController
    def index
      @families = FamilyAccount.includes(:owner, :child_profiles)
                               .order(created_at: :desc)
                               .limit(100)

      if params[:search].present?
        @families = @families.joins(:owner)
                            .where("users.name ILIKE ? OR users.email ILIKE ? OR family_accounts.name ILIKE ?",
                                   "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
      end
    end

    def show
      @family = FamilyAccount.includes(:owner, child_profiles: :books).find(params[:id])
      @child_profiles = @family.child_profiles
      @recent_books = Book.joins(:child_profile)
                          .where(child_profiles: { family_account_id: @family.id })
                          .order(created_at: :desc)
                          .limit(10)
    end
  end
end
