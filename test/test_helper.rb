ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def log_in_as(user)
      # Ensure user has completed onboarding to avoid magic link flow
      user.update!(onboarding_completed: true) unless user.onboarding_completed?
      post login_url, params: { email: user.email, password: "password123" }
    end

    # Override User.create! to set onboarding_completed: true by default in tests
    # This ensures test users can authenticate with passwords instead of magic links
    User.class_eval do
      class << self
        alias_method :original_create!, :create!

        def create!(*args, &block)
          attributes = args.first || {}
          # Set onboarding_completed: true by default if not specified and password is provided
          if attributes.is_a?(Hash) && attributes[:password].present? && !attributes.key?(:onboarding_completed)
            attributes[:onboarding_completed] = true
          end
          original_create!(*args, &block)
        end
      end
    end
  end
end
