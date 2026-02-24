module Admin
  class DashboardController < BaseController
    def index
      @stats = calculate_stats
      @recent_users = User.recent.limit(5)
      @recent_admin_actions = AdminAction.includes(:admin_user).recent.limit(10)
      @content_pending_moderation = Book.needs_moderation.count
    end

    private

    def calculate_stats
      {
        total_users: User.count,
        new_users_7_days: User.where("created_at >= ?", 7.days.ago).count,
        new_users_30_days: User.where("created_at >= ?", 30.days.ago).count,
        total_families: FamilyAccount.count,
        total_child_profiles: ChildProfile.count,
        total_books: Book.count,
        books_this_week: Book.where("created_at >= ?", 7.days.ago).count,
        total_story_generations: StoryGeneration.count,
        story_generations_this_week: StoryGeneration.where("created_at >= ?", 7.days.ago).count,
        total_page_generations: PageGeneration.count,
        page_generations_this_week: PageGeneration.where("created_at >= ?", 7.days.ago).count,
        ai_cost_7_days: calculate_ai_cost(7.days.ago),
        ai_cost_30_days: calculate_ai_cost(30.days.ago),
        content_pending_moderation: Book.needs_moderation.count
      }
    end

    def calculate_ai_cost(since)
      story_cost = StoryGeneration.where("created_at >= ?", since).sum(:cost_cents)
      page_cost = PageGeneration.where("created_at >= ?", since).sum(:cost_cents)
      (story_cost + page_cost) / 100.0 # Convert cents to dollars
    end
  end
end
