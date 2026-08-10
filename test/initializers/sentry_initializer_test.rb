# frozen_string_literal: true

require "test_helper"
require "ostruct"

class SentryInitializerTest < ActiveSupport::TestCase
  INITIALIZER_PATH = Rails.root.join("config/initializers/sentry.rb")

  setup do
    @original_dsn = ENV.fetch("SENTRY_DSN", nil)
    @original_sha = ENV.fetch("COMMIT_SHA", nil)
    @original_sentry_init = Sentry.method(:init)
  end

  teardown do
    if @original_dsn.nil?
      ENV.delete("SENTRY_DSN")
    else
      ENV["SENTRY_DSN"] = @original_dsn
    end
    if @original_sha.nil?
      ENV.delete("COMMIT_SHA")
    else
      ENV["COMMIT_SHA"] = @original_sha
    end
    Sentry.define_singleton_method(:init, &@original_sentry_init)
  end

  test "Sentry stays inert when SENTRY_DSN is absent" do
    ENV.delete("SENTRY_DSN")
    init_called = false
    Sentry.define_singleton_method(:init) { |&_| init_called = true }
    load INITIALIZER_PATH
    assert_not init_called, "Sentry.init must not be called when SENTRY_DSN is absent"
  end

  test "Sentry stays inert when SENTRY_DSN is blank" do
    ENV["SENTRY_DSN"] = "   "
    init_called = false
    Sentry.define_singleton_method(:init) { |&_| init_called = true }
    load INITIALIZER_PATH
    assert_not init_called, "Sentry.init must not be called when SENTRY_DSN is blank"
  end

  test "Sentry.init is called with DSN, environment, and release when SENTRY_DSN is set" do
    ENV["SENTRY_DSN"] = "https://test@sentry.io/123"
    ENV["COMMIT_SHA"] = "deadbeef"

    captured = nil
    Sentry.define_singleton_method(:init) do |&block|
      config = OpenStruct.new
      block&.call(config)
      captured = config
    end
    load INITIALIZER_PATH

    assert_not_nil captured, "Sentry.init was not called"
    assert_equal "https://test@sentry.io/123", captured.dsn
    assert_equal Rails.env.to_s, captured.environment
    assert_equal "deadbeef", captured.release
    assert_equal false, captured.send_default_pii
    assert_equal 1.0, captured.sample_rate
    assert captured.traces_sample_rate <= 0.1
    assert_respond_to captured.before_send, :call
  end

  test "before_send strips Authorization headers, clears cookies, and removes sensitive params" do
    ENV["SENTRY_DSN"] = "https://test@sentry.io/123"

    captured_before_send = nil
    Sentry.define_singleton_method(:init) do |&block|
      config = OpenStruct.new
      block&.call(config)
      captured_before_send = config.before_send
    end
    load INITIALIZER_PATH

    request = OpenStruct.new(
      headers: { "Authorization" => "Bearer secret", "Content-Type" => "application/json" },
      cookies: { "session_id" => "abc123" },
      data: { "password" => "hunter2", "username" => "alice", "token" => "xyz" }
    )
    event = OpenStruct.new(request: request)

    result = captured_before_send.call(event, {})

    assert_not result.request.headers.key?("Authorization"), "Authorization header must be stripped"
    assert result.request.headers.key?("Content-Type"), "Non-sensitive headers must be retained"
    assert_empty result.request.cookies, "Cookies must be cleared"
    assert_not result.request.data.key?("password"), "password param must be stripped"
    assert_not result.request.data.key?("token"), "token param must be stripped"
    assert result.request.data.key?("username"), "Non-sensitive params must be retained"
  end
end
