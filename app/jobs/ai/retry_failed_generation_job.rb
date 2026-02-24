# frozen_string_literal: true

module AI
  class RetryFailedGenerationJob < ApplicationJob
    queue_as :default

    def perform(page_generation_id)
      page_generation = PageGeneration.find(page_generation_id)

      return unless page_generation.can_retry?

      # Increment retry count
      page_generation.increment_retry_count!

      # Reset status and retry
      page_generation.update!(status: :pending)

      # Re-enqueue generation
      GeneratePageJob.perform_later(page_generation.id)
    end
  end
end
