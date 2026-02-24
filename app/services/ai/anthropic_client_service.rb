# frozen_string_literal: true

module AI
  class AnthropicClientService
    class APIError < StandardError; end
    class RateLimitError < APIError; end
    class TimeoutError < APIError; end

    def initialize(api_key: nil)
      @api_key = api_key || Rails.application.config.ai.anthropic_api_key
      @client = Anthropic::Client.new(access_token: @api_key)
    end

    def generate_text(prompt:, max_tokens: nil, temperature: nil, system: nil)
      max_tokens ||= Rails.application.config.ai.default_max_tokens
      temperature ||= Rails.application.config.ai.default_temperature

      messages = [ { role: "user", content: prompt } ]

      parameters = {
        model: Rails.application.config.ai.default_model,
        max_tokens: max_tokens,
        temperature: temperature,
        messages: messages
      }

      parameters[:system] = system if system.present?

      begin
        response = @client.messages(parameters: parameters)
        parse_response(response)
      rescue Faraday::TooManyRequestsError => e
        raise RateLimitError, "Rate limit exceeded: #{e.message}"
      rescue Faraday::TimeoutError => e
        raise TimeoutError, "Request timed out: #{e.message}"
      rescue StandardError => e
        raise APIError, "API request failed: #{e.message}"
      end
    end

    def analyze_image(image_data:, prompt:, max_tokens: nil)
      max_tokens ||= Rails.application.config.ai.default_max_tokens

      # Convert image to base64 if needed
      image_base64 = if image_data.is_a?(String)
        image_data
      else
        Base64.strict_encode64(image_data.read)
      end

      messages = [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type: "base64",
                media_type: "image/jpeg",
                data: image_base64
              }
            },
            {
              type: "text",
              text: prompt
            }
          ]
        }
      ]

      parameters = {
        model: Rails.application.config.ai.default_model,
        max_tokens: max_tokens,
        messages: messages
      }

      begin
        response = @client.messages(parameters: parameters)
        parse_response(response)
      rescue Faraday::TooManyRequestsError => e
        raise RateLimitError, "Rate limit exceeded: #{e.message}"
      rescue Faraday::TimeoutError => e
        raise TimeoutError, "Request timed out: #{e.message}"
      rescue StandardError => e
        raise APIError, "API request failed: #{e.message}"
      end
    end

    private

    def parse_response(response)
      {
        text: response.dig("content", 0, "text"),
        input_tokens: response.dig("usage", "input_tokens"),
        output_tokens: response.dig("usage", "output_tokens"),
        stop_reason: response.dig("stop_reason")
      }
    end
  end
end
