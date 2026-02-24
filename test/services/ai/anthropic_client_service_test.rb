# frozen_string_literal: true

require "test_helper"

module AI
  class AnthropicClientServiceTest < ActiveSupport::TestCase
    def setup
      @service = AnthropicClientService.new(api_key: "test_key")
    end

    test "should initialize with custom API key" do
      service = AnthropicClientService.new(api_key: "custom_key")
      assert_not_nil service
    end

    test "should initialize with default API key from config" do
      service = AnthropicClientService.new
      assert_not_nil service
    end

    test "generate_text should call API and return parsed response" do
      expected_response = {
        "content" => [{ "text" => "Generated text" }],
        "usage" => { "input_tokens" => 10, "output_tokens" => 20 },
        "stop_reason" => "end_turn"
      }

      mock_client = Minitest::Mock.new
      mock_client.expect(:messages, expected_response, [Hash])

      @service.instance_variable_set(:@client, mock_client)

      result = @service.generate_text(prompt: "Test prompt")

      assert_equal "Generated text", result[:text]
      assert_equal 10, result[:input_tokens]
      assert_equal 20, result[:output_tokens]
      assert_equal "end_turn", result[:stop_reason]

      mock_client.verify
    end

    test "generate_text should handle rate limit errors" do
      mock_client = Minitest::Mock.new
      mock_client.expect(:messages, -> { raise Faraday::TooManyRequestsError.new("Rate limited") }, [Hash])

      @service.instance_variable_set(:@client, mock_client)

      assert_raises(AnthropicClientService::RateLimitError) do
        @service.generate_text(prompt: "Test")
      end
    end

    test "generate_text should handle timeout errors" do
      mock_client = Minitest::Mock.new
      mock_client.expect(:messages, -> { raise Faraday::TimeoutError.new("Timeout") }, [Hash])

      @service.instance_variable_set(:@client, mock_client)

      assert_raises(AnthropicClientService::TimeoutError) do
        @service.generate_text(prompt: "Test")
      end
    end

    test "generate_text should handle generic API errors" do
      mock_client = Minitest::Mock.new
      mock_client.expect(:messages, -> { raise StandardError.new("API error") }, [Hash])

      @service.instance_variable_set(:@client, mock_client)

      assert_raises(AnthropicClientService::APIError) do
        @service.generate_text(prompt: "Test")
      end
    end

    test "analyze_image should accept base64 string" do
      expected_response = {
        "content" => [{ "text" => "Image analysis result" }],
        "usage" => { "input_tokens" => 100, "output_tokens" => 200 }
      }

      mock_client = Minitest::Mock.new
      mock_client.expect(:messages, expected_response, [Hash])

      @service.instance_variable_set(:@client, mock_client)

      result = @service.analyze_image(
        image_data: "base64encodedstring",
        prompt: "Analyze this"
      )

      assert_equal "Image analysis result", result[:text]
      assert_equal 100, result[:input_tokens]
      assert_equal 200, result[:output_tokens]
    end
  end
end
