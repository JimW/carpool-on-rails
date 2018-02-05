require 'simplecov'     # Must come first
# SimpleCov.start 'rails'
SimpleCov.start do
  load_profile "test_frameworks"
  add_filter %r{^/config/}
  add_filter %r{^/db/}
  add_filter %r{^/app/policies/}
  add_group "GraphQL", "app/graphql" 
  add_group "Controllers", "app/controllers"
  add_group "ActiveAdmin", "app/admin"
  add_group "Channels", "app/channels" if defined?(ActionCable)
  add_group "Models", "app/models"
  # add_group "Mailers", "app/mailers"
  add_group "Helpers", "app/helpers"
  add_group "Jobs", %w[app/jobs app/workers]
  add_group "Services", "app/services"

  add_group "Libraries", "lib/"
  track_files "{app,lib}/**/*.rb"
end

ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/pride"        # for colorful output
require 'minitest/reporters'
require 'test_setups'

ActiveJob::Base.queue_adapter = :test # allows the Google related jobs that happen on after_save to not screw up tests

# Minitest::Reporters.use!
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

# include Warden::Test::Helpers
# https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara

# https://github.com/DatabaseCleaner/database_cleaner#minitest-example

# Capybara.register_driver :selenium do |app|
#   Capybara::Selenium::Driver.new(app, browser: :chrome)
# end
# Capybara.javascript_driver = :chrome
# Capybara.configure do |config|
#   config.default_max_wait_time = 10 # seconds
#   config.default_driver = :selenium
# end


class ActiveSupport::TestCase
  # include FactoryBot::Syntax::Methods
  self.use_instantiated_fixtures = true
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include TestSetups
  # include Devise::Test::T

end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include TestSetups
end

# class ActionDispatch::IntegrationTest
#   def sign_in(user)
#     post user_session_path \
#       "user[email]"    => user.email,
#       "user[password]" => user.password
#   end
# end

# http://docs.seattlerb.org/minitest/Minitest/Assertions.html