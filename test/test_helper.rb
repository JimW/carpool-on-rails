ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require 'minitest/reporters'
require "minitest/rails/capybara"

# include Warden::Test::Helpers
# https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara


# Uncomment for awesome colorful output
require "minitest/pride"

Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  self.use_instantiated_fixtures = true

  fixtures :all
  # Add more helper methods to be used by all tests here...
end
