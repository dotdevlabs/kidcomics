# frozen_string_literal: true

module AI
  class StoryGenerationService
    class ValidationError < StandardError; end

    def initialize(book:, user_prompt:)
      @book = book
      @user_prompt = user_prompt
    end

    def call
      validate!

      story_generation = create_story_generation
      enqueue_pipeline(story_generation)

      story_generation
    end

    private

    def validate!
      raise ValidationError, "Book must have drawings" unless @book.has_drawings?
      raise ValidationError, "AI generation is disabled for this book" unless @book.ai_generation_enabled?
      raise ValidationError, "Story prompt is required" if @user_prompt.blank?
    end

    def create_story_generation
      @book.story_generations.create!(
        status: :pending,
        prompt_template: @user_prompt
      )
    end

    def enqueue_pipeline(story_generation)
      AI::AnalyzeDrawingsJob.perform_later(story_generation.id)
    end
  end
end
