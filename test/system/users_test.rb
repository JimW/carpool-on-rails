require "application_system_test_case"

class Users::LoginTest < ApplicationSystemTestCase
  
  def setup
    @org = organizations(:dtech)

    @lobby = carpools(:lobby)
    # these will simply do not work properly when assigned within a fixture, so here they are: (maybe it's the has_many_through with scopes that trip it up, maybe a bug in rails..?)
    @lobby.active_drivers << users(:driver1, :driver2) 
    @lobby.active_passengers << users(:passenger1, :passenger2)
    @lobby.save!

    @main_carpool = carpools(:main)
    @main_carpool.active_drivers << users(:driver1, :driver2)
    @main_carpool.active_passengers << users(:passenger2)
    @main_carpool.save!

    @driver1 = users(:driver1)
    @driver1.current_carpool = @main_carpool

    @driver2 = users(:driver2)
    @driver2.current_carpool = @main_carpool

    @passenger1 = users(:passenger1)
    @passenger1.current_carpool = @main_carpool

  end

  test "bad password login" do
    sign_in_with @driver1.email, "f"
    assert_text 'Invalid Email or password'
  end

  test "valid login for admin" do
    sign_in_with @driver1.email, "a"
    assert_text carpools(:main).title

    # https://stackoverflow.com/questions/47604409/setting-current-user-in-system-tests
    # https://github.com/rails/rails/pull/30638
    # Rails 5.1 (fixed in 5.2 beta) is screwing up config for puma maybe, related to current_user problem that is popping up.
    assert_text @driver1.current_carpool.title
  end

  test "valid login for manager" do
 
    sign_in_with @driver2.email, "a"
    screenshot_and_save_page
    # assert_redirected_to 'admin/routes'
    # assert_text "Routes for" # + @driver2.current_carpool.title
    assert_text @driver2.current_carpool.title

  end

  # test "valid login via google" do
  #   assert(true)
  # end

end