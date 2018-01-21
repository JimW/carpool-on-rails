require "test_helper"
require "minitest/rails/capybara"
require 'capybara-screenshot/minitest'

# http://api.rubyonrails.org/v5.1.4/classes/ActionDispatch/SystemTestCase.html
# http://api.rubyonrails.org/v5.1.4/classes/ActionDispatch/SystemTesting/TestHelpers/ScreenshotHelper.html

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  # driven_by :poltergeist, screen_size: [1400, 1400], options:
  # { js_errors: true }
  
  Capybara.register_driver :headless_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w(headless disable-gpu) }
    )
    Capybara::Selenium::Driver.new app,
      browser: :chrome,
      desired_capabilities: capabilities
  end

  include Capybara::Screenshot::MiniTestPlugin
  # Capybara::Screenshot.autosave_on_failure = false
  # Capybara::Screenshot.testunit_paths << 'test/system'
  # Capybara.asset_host = 'http://localhost:3000' # Better looking HTML screenshots, need a server running though..
  # Capybara.save_path = "/file/path"

  # require 'capybara/poltergeist'
  # Capybara.javascript_driver = :poltergeist

  def sign_in_with(email, password)
    visit 'admin/login'
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Login'
  end

end

# Maybe useful:
# https://github.com/ytbryan/rails-devise

# https://github.com/teamcapybara/capybara#using-capybara-with-minitest
# http://ngauthier.com/2017/09/rails-system-tests-with-headless-chrome-on-windows-bash-wsl.html