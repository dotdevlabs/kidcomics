# frozen_string_literal: true

module AI
  class GeneratePageJob < ApplicationJob
    queue_as :default

    retry_on AnthropicClientService::RateLimitError, wait: :exponentially_longer, attempts: 3
    retry_on AnthropicClientService::TimeoutError, wait: 5.seconds, attempts: 2

    def perform(page_generation_id)
      page_generation = PageGeneration.find(page_generation_id)
      story_generation = page_generation.story_generation

      # Generate the page content
      PageGeneratorService.new(
        page_generation: page_generation
      ).call

      # Check if all pages are completed
      check_completion(story_generation)
    rescue AnthropicClientService::APIError => e
      handle_failure(page_generation, e.message)
    rescue StandardError => e
      handle_failure(page_generation, e.message)
      raise
    end

    private

    def check_completion(story_generation)
      if story_generation.all_pages_completed?
        story_generation.mark_as_completed!
        # Broadcast completion via Turbo Stream (if needed)
        broadcast_completion(story_generation)
      end
    end

    def handle_failure(page_generation, error_message)
      page_generation.mark_as_failed!(error_message)

      # Retry if possible
      if page_generation.can_retry?
        RetryFailedGenerationJob.set(wait: 30.seconds).perform_later(page_generation.id)
      end
    end

    def broadcast_completion(story_generation)
      # Future: Broadcast via Turbo Stream for real-time updates
      # Turbo::StreamsChannel.broadcast_replace_to(
      #   "story_generation_#{story_generation.id}",
      #   target: "story_generation_status",
      #   partial: "ai/story_generations/status",
      #   locals: { story_generation: story_generation }
      # )
    end
  end
end
