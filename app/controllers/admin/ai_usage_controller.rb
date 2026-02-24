module Admin
  class AiUsageController < BaseController
    def index
      @date_range = params[:days]&.to_i || 30
      @start_date = @date_range.days.ago

      @stats = {
        total_story_generations: StoryGeneration.where("created_at >= ?", @start_date).count,
        total_page_generations: PageGeneration.where("created_at >= ?", @start_date).count,
        total_character_extractions: CharacterExtraction.where("created_at >= ?", @start_date).count,
        story_cost: StoryGeneration.where("created_at >= ?", @start_date).sum(:cost_cents) / 100.0,
        page_cost: PageGeneration.where("created_at >= ?", @start_date).sum(:cost_cents) / 100.0,
        total_cost: (StoryGeneration.where("created_at >= ?", @start_date).sum(:cost_cents) +
                     PageGeneration.where("created_at >= ?", @start_date).sum(:cost_cents)) / 100.0
      }

      # Most active families by AI usage
      @top_families = FamilyAccount
        .joins(child_profiles: { books: :story_generations })
        .where("story_generations.created_at >= ?", @start_date)
        .group("family_accounts.id", "family_accounts.name")
        .select("family_accounts.id, family_accounts.name, COUNT(story_generations.id) as generation_count")
        .order("generation_count DESC")
        .limit(10)

      # Failed generations
      @failed_story_generations = StoryGeneration
        .where("created_at >= ?", @start_date)
        .where.not(error_message: nil)
        .order(created_at: :desc)
        .limit(10)

      @failed_page_generations = PageGeneration
        .where("created_at >= ?", @start_date)
        .where.not(error_message: nil)
        .order(created_at: :desc)
        .limit(10)

      # Usage over time (grouped by day)
      @daily_usage = StoryGeneration
        .where("created_at >= ?", @start_date)
        .group("DATE(created_at)")
        .select("DATE(created_at) as date, COUNT(*) as count, SUM(cost_cents) as cost")
        .order("date DESC")
    end
  end
end
