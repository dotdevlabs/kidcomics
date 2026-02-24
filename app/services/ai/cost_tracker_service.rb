# frozen_string_literal: true

module AI
  class CostTrackerService
    # Cost in cents per million tokens
    INPUT_TOKEN_COST = Rails.application.config.ai.cost_per_million_input_tokens
    OUTPUT_TOKEN_COST = Rails.application.config.ai.cost_per_million_output_tokens

    def self.calculate_cost(input_tokens:, output_tokens:)
      input_cost = (input_tokens.to_f / 1_000_000) * INPUT_TOKEN_COST
      output_cost = (output_tokens.to_f / 1_000_000) * OUTPUT_TOKEN_COST

      total_cents = (input_cost + output_cost).round
      total_cents
    end

    def self.track_api_call(generation:, input_tokens:, output_tokens:)
      cost_cents = calculate_cost(input_tokens: input_tokens, output_tokens: output_tokens)

      current_cost = generation.cost_cents || 0
      generation.update!(cost_cents: current_cost + cost_cents)

      {
        cost_cents: cost_cents,
        total_cost_cents: current_cost + cost_cents,
        input_tokens: input_tokens,
        output_tokens: output_tokens
      }
    end

    def self.update_generation_cost(story_generation:)
      total_cost = story_generation.page_generations.sum(:cost_cents)
      story_generation.update!(cost_cents: total_cost)
    end
  end
end
