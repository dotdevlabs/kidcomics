# frozen_string_literal: true

module AI
  class AnalyzeDrawingsJob < ApplicationJob
    queue_as :default

    def perform(story_generation_id)
      story_generation = StoryGeneration.find(story_generation_id)
      book = story_generation.book

      story_generation.update!(status: :analyzing_drawings)

      # Analyze each drawing
      book.drawings.each do |drawing|
        DrawingAnalysisService.new(
          drawing: drawing,
          story_generation: story_generation
        ).call
      rescue StandardError => e
        Rails.logger.error("Failed to analyze drawing #{drawing.id}: #{e.message}")
        # Continue with other drawings
      end

      # Once all drawings are analyzed, proceed to story generation
      GenerateStoryOutlineJob.perform_later(story_generation.id)
    rescue StandardError => e
      story_generation.mark_as_failed!("Drawing analysis failed: #{e.message}")
      raise
    end
  end
end
