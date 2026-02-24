# frozen_string_literal: true

module AI
  class GenerateStoryOutlineJob < ApplicationJob
    queue_as :default

    def perform(story_generation_id)
      story_generation = StoryGeneration.find(story_generation_id)

      # Generate the story outline
      StoryOutlineGeneratorService.new(
        story_generation: story_generation
      ).call

      # Update status to generating illustrations
      story_generation.update!(status: :generating_illustrations)

      # Enqueue page generation jobs for each page
      story_generation.page_generations.ordered.each do |page_generation|
        GeneratePageJob.perform_later(page_generation.id)
      end
    rescue StandardError => e
      story_generation.mark_as_failed!("Story outline generation failed: #{e.message}")
      raise
    end
  end
end
