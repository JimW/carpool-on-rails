require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @org = organizations(:dtech)

    @lobby = carpools(:lobby)
    # these will simply do not work properly when assigned within a fixture, so here they are: (maybe it's the has_many_through with scopes that trip it up, maybe a bug in rails..?)
    @lobby.active_drivers << users(:driver1, :driver2) 
    @lobby.active_passengers << users(:passenger1, :passenger2)

    @main_carpool = carpools(:main)
    @main_carpool.active_drivers << users(:driver1, :driver2)
    @main_carpool.active_passengers << users(:passenger2)

    @driver1 = users(:driver1)
    @passenger1 = users(:passenger1)
    @driver1.current_carpool = @main_carpool # I thought this was smart and would auto select the first non lobby carpool ???
  end

  test "associations" do
    assert_includes @driver1.organizations, organizations(:dtech) 
    assert @driver1.current_carpool == @main_carpool
    assert @driver1.active_carpools.count == 2 
    assert @driver1.driver_memberships.count == 2
    assert_includes @driver1.driver_memberships, carpools(:main) 
    assert_includes @driver1.driver_memberships, carpools(:lobby) 

    # Not using these, just take them out !!!
    assert_includes @passenger1.passenger_memberships, carpools(:lobby) 
    assert @passenger1.passenger_memberships.count == 1 # just the lobby
    assert @passenger1.active_carpools.count == 1
  end

  test 'scopes' do
    assert_includes User.in_lobby, users(:driver1)
    assert_includes User.in_lobby, users(:passenger1)
    refute_includes User.all_can_drive, users(:passenger1)
    refute_includes User.all_google_calendar_subscribers, users(:passenger1)
  end

  test 'reset_current_carpool' do
    @driver1.current_carpool = carpools(:lobby)
    @driver1.reset_current_carpool
    assert @driver1.current_carpool == carpools(:main)
    @driver1.carpools.delete(@driver1.current_carpool)
    @driver1.reset_current_carpool
    assert @driver1.current_carpool == carpools(:lobby)
  end

  test 'full_name' do
    assert @driver1.full_name == "Jim Aa"
  end

  test 'short_name' do
    assert @driver1.short_name == "Jim"
  end

  test 'short_name_with_mobile_phone' do
    assert @driver1.short_name_with_mobile_phone == "Jim (415) 555-5555"
  end

  test 'full_name_with_mobile_phone' do
    assert @driver1.full_name_with_mobile_phone == "Jim Aa (415) 555-5555"
  end

  test "is_admin?" do
    assert @driver1.is_admin?
    assert_not @driver2.is_admin?
  end

  test "is_manager?" do
    assert_not @driver1.is_manager? carpools(:main)
    @driver1.add_role(:manager, carpools(:main))
    assert @driver1.is_manager? carpools(:main)
    assert @driver2.is_manager? carpools(:main)
  end

end
