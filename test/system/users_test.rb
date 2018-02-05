require "application_system_test_case"

class Users::LoginTest < ApplicationSystemTestCase
  
  def setup
    setup_5_routes_on_main_carpool
  end

  test "bad password login" do
    # sign_in_with @driver1.email, "f"
    visit 'admin/login'
    fill_in 'Email', with: @driver1.email
    fill_in 'Password', with: "badpassword"
    click_on 'Login'
    expect(page).to have_content 'Invalid Email or password'
  end

  test "valid login for admin" do
    # Capybara.current_driver = :poltergeist
    # ...
    # Capybara.use_default_driver

    visit 'admin/login'
    fill_in 'Email', with: @driver1.email
    fill_in 'Password', with: "a"
    click_on 'Login'

    all 'div.flash.flash_notice', count: 1

    expect(page).to has_current_path('/admin/carpools')
    expect(page).to have_content 'Signed in successfully.'
    screenshot_and_save_page

    # https://stackoverflow.com/questions/47604409/setting-current-user-in-system-tests
    # https://github.com/rails/rails/pull/30638
    # Rails 5.1 (fixed in 5.2 beta) is screwing up config for puma maybe, related to current_user problem that is popping up.
    # assert_text @driver1.current_carpool.title
  end

  test "valid login for manager" do
 
    visit 'admin/login'
    fill_in 'Email', with: @driver2.email
    fill_in 'Password', with: "a"
    click_on 'Login'

    expect(page).to have_current_path('/admin/routes')
    screenshot_and_save_page

    # assert_redirected_to 'admin/routes'
    # assert_text "Routes for" # + @driver2.current_carpool.title
    assert_text @driver2.current_carpool.title

  end

  # test "valid login via google" do
  #   assert(true)
  # end

end

# https://github.com/teamcapybara/capybara#querying
# http://www.rubydoc.info/github/teamcapybara/capybara/master/Capybara/Node/Matchers
