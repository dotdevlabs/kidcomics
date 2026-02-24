# frozen_string_literal: true

module AI
  class DrawingAnalysisService
    def initialize(drawing:, story_generation:)
      @drawing = drawing
      @story_generation = story_generation
      @client = AnthropicClientService.new
      @prompt_builder = PromptBuilderService.new(story_generation: story_generation)
    end

    def call
      return unless @drawing.image.attached?

      @drawing.update!(analysis_status: :analyzing)

      analysis_result = analyze_drawing
      save_analysis(analysis_result)

      @drawing.analysis_status_completed? ? @drawing : nil
    rescue AnthropicClientService::APIError => e
      @drawing.update!(analysis_status: :failed)
      Rails.logger.error("Drawing analysis failed: #{e.message}")
      raise
    end

    private

    def analyze_drawing
      image_data = download_image

      prompt = @prompt_builder.build_character_analysis_prompt

      response = @client.analyze_image(
        image_data: image_data,
        prompt: prompt,
        max_tokens: 2000
      )

      parse_analysis_response(response[:text])
    end

    def download_image
      # Download the image blob
      @drawing.image.download
    end

    def parse_analysis_response(text)
      # Try to extract JSON from the response
      json_match = text.match(/\{.*\}/m)
      return nil unless json_match

      JSON.parse(json_match[0])
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse analysis response: #{e.message}")
      nil
    end

    def save_analysis(analysis_result)
      return unless analysis_result

      @drawing.update!(
        analysis_status: :completed,
        analysis_data: analysis_result,
        is_character: analysis_result["is_character"],
        extracted_at: Time.current
      )

      # Create character extraction if this is a character drawing
      if analysis_result["is_character"]
        create_character_extraction(analysis_result)
      end
    end

    def create_character_extraction(analysis_result)
      CharacterExtraction.create!(
        drawing: @drawing,
        story_generation: @story_generation,
        character_name: analysis_result["character_name"],
        description: analysis_result["description"],
        color_palette: analysis_result["color_palette"] || {},
        proportions: analysis_result["proportions"] || {},
        status: :completed
      )
    end
  end
end
