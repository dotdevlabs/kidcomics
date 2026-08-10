# frozen_string_literal: true

if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environment = Rails.env
    config.release = ENV["COMMIT_SHA"]
    config.send_default_pii = false
    config.sample_rate = 1.0
    config.traces_sample_rate = 0.1

    config.before_send = lambda do |event, _hint|
      if (req = event.request)
        if req.headers.is_a?(Hash)
          req.headers = req.headers.reject { |k, _| /\Aauthorization\z/i.match?(k.to_s) }
        end
        req.cookies = {}
        if req.data.is_a?(Hash)
          req.data = req.data.reject { |k, _| /password|token|secret/i.match?(k.to_s) }
        end
      end
      event
    end
  end
end
