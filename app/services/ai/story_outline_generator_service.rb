# frozen_string_literal: true

module AI
  class StoryOutlineGeneratorService
    def initialize(story_generation:)
      @story_generation = story_generation
      @client = AnthropicClientService.new
      @prompt_builder = PromptBuilderService.new(story_generation: story_generation)
    end

    def call
      @story_generation.update!(status: :generating_story)

      character_summaries = gather_character_summaries
      outline_data = generate_story_outline(character_summaries)
      save_outline(outline_data)

      @story_generation
    rescue AnthropicClientService::APIError => e
      @story_generation.mark_as_failed!("Story generation failed: #{e.message}")
      Rails.logger.error("Story outline generation failed: #{e.message}")
      raise
    end

    private

    def gather_character_summaries
      @story_generation.character_extractions.status_completed.map do |extraction|
        <<~SUMMARY
          Character: #{extraction.character_name || 'Unnamed'}
          Description: #{extraction.description}
          Visual Style: #{extraction.color_palette&.dig('primary')&.join(', ') || 'Not specified'}
        SUMMARY
      end
    end

    def generate_story_outline(character_summaries)
      user_prompt = @story_generation.prompt_template

      prompt = @prompt_builder.build_story_outline_prompt(
        user_prompt: user_prompt,
        character_summaries: character_summaries
      )

      response = @client.generate_text(
        prompt: prompt,
        max_tokens: 3000,
        temperature: 0.7
      )

      # Track cost
      CostTrackerService.track_api_call(
        generation: @story_generation,
        input_tokens: response[:input_tokens],
        output_tokens: response[:output_tokens]
      )

      parse_outline_response(response[:text])
    end

    def parse_outline_response(text)
      # Try to extract JSON from the response
      json_match = text.match(/\{.*\}/m)
      return nil unless json_match

      JSON.parse(json_match[0])
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse outline response: #{e.message}")
      # Return a basic structure if parsing fails
      {
        "title" => "Untitled Story",
        "total_pages" => 6,
        "outline" => text,
        "pages" => []
      }
    end

    def save_outline(outline_data)
      return unless outline_data

      @story_generation.update!(
        story_outline: outline_data["outline"],
        character_data: {
          title: outline_data["title"],
          total_pages: outline_data["total_pages"]
        }
      )

      # Create page generation records
      create_page_generations(outline_data["pages"])
    end

    def create_page_generations(pages_data)
      return if pages_data.blank?

      pages_data.each do |page_data|
        PageGeneration.create!(
          story_generation: @story_generation,
          book: @story_generation.book,
          page_number: page_data["page_number"],
          status: :pending,
          prompt: page_data["scene_description"],
          panel_layout: {
            characters: page_data["characters"] || [],
            setting: page_data["setting"]
          }
        )
      end
    end
  end
end
