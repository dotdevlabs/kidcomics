# frozen_string_literal: true

require "test_helper"

module AI
  class AnthropicClientServiceTest < ActiveSupport::TestCase
    test "should initialize with custom API key" do
      service = AI::AnthropicClientService.new(api_key: "custom_key")
      assert_not_nil service
    end

    test "should initialize with default API key from config" do
      # Temporarily set a test API key
      original_key = Rails.application.config.ai.anthropic_api_key
      Rails.application.config.ai.anthropic_api_key = "test_default_key"

      service = AI::AnthropicClientService.new
      assert_not_nil service

      # Restore original key
      Rails.application.config.ai.anthropic_api_key = original_key
    end

    test "parse_response should extract text and tokens" do
      service = AI::AnthropicClientService.new(api_key: "test_key")

      response = {
        "content" => [ { "text" => "Generated text" } ],
        "usage" => { "input_tokens" => 10, "output_tokens" => 20 },
        "stop_reason" => "end_turn"
      }

      result = service.send(:parse_response, response)

      assert_equal "Generated text", result[:text]
      assert_equal 10, result[:input_tokens]
      assert_equal 20, result[:output_tokens]
      assert_equal "end_turn", result[:stop_reason]
    end

    test "should raise RateLimitError for rate limit errors" do
      assert AI::AnthropicClientService::RateLimitError < AI::AnthropicClientService::APIError
    end

    test "should raise TimeoutError for timeout errors" do
      assert AI::AnthropicClientService::TimeoutError < AI::AnthropicClientService::APIError
    end

    test "should have APIError as base error class" do
      assert AI::AnthropicClientService::APIError < StandardError
    end
  end
end
