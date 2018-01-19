require 'test_helper'

class CarpoolTest < ActiveSupport::TestCase
  
  def setup
    @org = organizations(:dtech)
    @main_carpool = carpools(:main)
    @lobby = carpools(:lobby)

    @main_carpool.drivers << users(:driver1, :driver2)
    @main_carpool.passengers << users(:passenger1, :passenger2)
  end

  test "associations" do
    assert @main_carpool.users.count == 4
    assert @main_carpool.drivers.count == 2
    assert @main_carpool.passengers.count == 2
    assert @main_carpool.active_drivers.count == 2
    assert @main_carpool.active_passengers.count == 2
    # assert @main_carpool.routes.count == 3
  end

  test "is_lobby?" do
    assert_not @main_carpool.is_lobby?
    assert @lobby.is_lobby?
  end

end
