# frozen_string_literal: true

# AI Service Configuration
Rails.application.config.ai = ActiveSupport::OrderedOptions.new

# Anthropic API configuration
Rails.application.config.ai.anthropic_api_key = ENV.fetch("ANTHROPIC_API_KEY", nil)

# Generation settings
Rails.application.config.ai.max_retries = ENV.fetch("MAX_GENERATION_RETRIES", "3").to_i
Rails.application.config.ai.timeout = ENV.fetch("GENERATION_TIMEOUT_SECONDS", "30").to_i
Rails.application.config.ai.default_model = ENV.fetch("ANTHROPIC_MODEL", "claude-3-5-sonnet-20241022")
Rails.application.config.ai.default_max_tokens = ENV.fetch("DEFAULT_MAX_TOKENS", "4096").to_i
Rails.application.config.ai.default_temperature = ENV.fetch("DEFAULT_TEMPERATURE", "0.7").to_f

# Cost tracking (in cents per million tokens)
Rails.application.config.ai.cost_per_million_input_tokens = ENV.fetch("COST_PER_MILLION_INPUT_TOKENS", "300").to_i
Rails.application.config.ai.cost_per_million_output_tokens = ENV.fetch("COST_PER_MILLION_OUTPUT_TOKENS", "1500").to_i

# Generation target time per page (in seconds)
Rails.application.config.ai.target_time_per_page = ENV.fetch("TARGET_TIME_PER_PAGE", "30").to_i

# Log warning if API key is not configured in production
if Rails.env.production? && Rails.application.config.ai.anthropic_api_key.blank?
  Rails.logger.warn "ANTHROPIC_API_KEY is not configured. AI features will not work."
end
