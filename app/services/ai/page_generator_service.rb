# frozen_string_literal: true

module AI
  class PageGeneratorService
    def initialize(page_generation:)
      @page_generation = page_generation
      @story_generation = page_generation.story_generation
      @client = AnthropicClientService.new
      @prompt_builder = PromptBuilderService.new(story_generation: @story_generation)
    end

    def call
      start_time = Time.current
      @page_generation.update!(status: :generating)

      page_content = generate_page_content
      save_page_content(page_content)

      generation_time = Time.current - start_time
      @page_generation.mark_as_completed!(
        generation_time: generation_time,
        cost_cents: @page_generation.cost_cents || 0
      )

      @page_generation
    rescue AnthropicClientService::APIError => e
      @page_generation.mark_as_failed!("Page generation failed: #{e.message}")
      Rails.logger.error("Page generation failed for page #{@page_generation.page_number}: #{e.message}")
      raise
    end

    private

    def generate_page_content
      scene_description = @page_generation.prompt

      prompt = @prompt_builder.build_page_prompt(
        page_number: @page_generation.page_number,
        scene_description: scene_description
      )

      response = @client.generate_text(
        prompt: prompt,
        max_tokens: 2000,
        temperature: 0.7
      )

      # Track cost
      cost_info = CostTrackerService.track_api_call(
        generation: @page_generation,
        input_tokens: response[:input_tokens],
        output_tokens: response[:output_tokens]
      )

      parse_page_response(response[:text])
    end

    def parse_page_response(text)
      # Try to extract JSON from the response
      json_match = text.match(/\{.*\}/m)
      return nil unless json_match

      JSON.parse(json_match[0])
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse page response: #{e.message}")
      # Return a basic structure if parsing fails
      {
        "narration" => text.truncate(500),
        "dialogue" => [],
        "panel_layout" => { "type" => "full_page" },
        "illustration_prompt" => "Scene from a children's story"
      }
    end

    def save_page_content(page_content)
      return unless page_content

      @page_generation.update!(
        narration_text: page_content["narration"],
        dialogue_data: page_content["dialogue"] || [],
        panel_layout: page_content["panel_layout"] || {},
        prompt: page_content["illustration_prompt"]
      )
    end
  end
end
