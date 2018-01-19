require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/pride"        # for colorful output
require 'minitest/reporters'
require "minitest/rails/capybara"
# require 'minitest/autorun' # need this???

# include Warden::Test::Helpers
# https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara

Minitest::Reporters.use!

class ActiveSupport::TestCase
  
  self.use_instantiated_fixtures = true

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # Add more helper methods to be used by all tests here...

end
