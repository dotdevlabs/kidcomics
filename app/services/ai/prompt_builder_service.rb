# frozen_string_literal: true

module AI
  class PromptBuilderService
    def initialize(story_generation:, page_context: nil)
      @story_generation = story_generation
      @page_context = page_context
    end

    def build_character_references
      character_extractions = @story_generation.character_extractions.status_completed

      return "" if character_extractions.empty?

      references = character_extractions.map do |extraction|
        <<~CHARACTER
          Character: #{extraction.character_name || 'Unnamed'}
          Description: #{extraction.description}
          Colors: #{extraction.color_palette.to_json}
          Proportions: #{extraction.proportions.to_json}
        CHARACTER
      end

      <<~SECTION
        ## Character References
        These are the characters that appear in this story. Maintain consistency with these descriptions:

        #{references.join("\n")}
      SECTION
    end

    def build_style_references
      style_data = @story_generation.style_data

      return "" if style_data.blank?

      <<~SECTION
        ## Art Style Guidelines
        #{style_data['description'] || 'Maintain consistency with the child\'s drawing style'}

        Key characteristics:
        - Line style: #{style_data['line_style'] || 'Simple, child-like'}
        - Color approach: #{style_data['color_approach'] || 'Bright, vibrant'}
        - Detail level: #{style_data['detail_level'] || 'Age-appropriate'}
      SECTION
    end

    def build_story_context
      outline = @story_generation.story_outline

      return "" if outline.blank?

      <<~SECTION
        ## Story Context
        #{outline}
      SECTION
    end

    def build_page_prompt(page_number:, scene_description:)
      character_refs = build_character_references
      style_refs = build_style_references
      story_context = build_story_context

      <<~PROMPT
        You are helping create an illustrated children's story book. Generate content for page #{page_number}.

        #{story_context}

        #{character_refs}

        #{style_refs}

        ## This Page's Scene
        #{scene_description}

        ## Your Task
        Generate the following for this page in JSON format:

        {
          "narration": "2-3 sentences of narration text appropriate for children",
          "dialogue": [
            {
              "character": "character name",
              "text": "what they say",
              "position": "top|middle|bottom"
            }
          ],
          "panel_layout": {
            "type": "full_page|split_horizontal|split_vertical",
            "focus": "description of main visual focus"
          },
          "illustration_prompt": "Detailed prompt for generating an illustration that matches the child's art style and character designs"
        }

        Keep dialogue age-appropriate, simple, and engaging. The illustration prompt should be detailed enough to maintain character and style consistency.
      PROMPT
    end

    def build_story_outline_prompt(user_prompt:, character_summaries:)
      <<~PROMPT
        You are helping create a children's story book based on a child's drawings.

        ## Characters from Drawings
        #{character_summaries.join("\n\n")}

        ## User's Story Prompt
        #{user_prompt}

        ## Your Task
        Create a story outline for a 4-8 page children's book that:
        1. Incorporates the characters from the child's drawings
        2. Follows the user's story direction
        3. Is age-appropriate and engaging
        4. Has a clear beginning, middle, and end
        5. Includes opportunities for illustration on each page

        Return your response in JSON format:

        {
          "title": "Suggested story title",
          "total_pages": 6,
          "outline": "Brief story summary",
          "pages": [
            {
              "page_number": 1,
              "scene_description": "What happens on this page",
              "characters": ["list", "of", "characters"],
              "setting": "where the scene takes place"
            }
          ]
        }
      PROMPT
    end

    def build_character_analysis_prompt
      <<~PROMPT
        Analyze this drawing to extract character information. Look for:

        1. Character identification: Is this a person, animal, or creature? Describe them.
        2. Visual characteristics: Colors, shapes, proportions, distinctive features
        3. Style elements: Line quality, shading, artistic approach
        4. Color palette: Main colors used

        Return your analysis in JSON format:

        {
          "is_character": true/false,
          "character_name": "Suggested name based on appearance",
          "description": "Detailed visual description",
          "color_palette": {
            "primary": ["list", "of", "main", "colors"],
            "secondary": ["list", "of", "accent", "colors"]
          },
          "proportions": {
            "body_type": "description",
            "distinctive_features": ["list of unique traits"]
          }
        }

        If this is not a character drawing (e.g., it's a background, object, or abstract), set is_character to false and provide appropriate analysis.
      PROMPT
    end

    def build_consistency_instructions
      <<~INSTRUCTIONS
        CRITICAL: Maintain absolute consistency with the character descriptions and art style provided.
        - Use the exact colors specified in character color palettes
        - Match the proportions and features described
        - Keep the art style consistent with the child's original drawings
        - Do not introduce new characters or drastically alter existing ones
      INSTRUCTIONS
    end
  end
end
