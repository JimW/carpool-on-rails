module TestSetups

  def setup_5_routes_on_main_carpool

    @org = organizations(:dtech)
    @lobby = carpools(:lobby)
    @lobby.active_drivers << users(:driver1, :driver2) 
    @lobby.active_passengers << users(:passenger2)

    @main_carpool = carpools(:main)
    @main_carpool.active_drivers << users(:driver1, :driver2)
    @main_carpool.active_passengers << users(:passenger1, :passenger2)

    @instance1 = routes(:instance1)
    @instance1.event = events(:instance1)
    
    @modified_instance1 = routes(:modified_instance1)
    @modified_instance1.event = events(:modified_instance1)
    @modified_instance1.save!

    @template1 = routes(:template1)
    @template1.event = events(:template1)
    @template1.scheduled_instances << @instance1

    @template2 = routes(:template2)
    @template2.event = events(:template2)
    @template1.scheduled_instances << @modified_instance1

    @special1 = routes(:special1)
    @special1.event = events(:special1)

    @main_carpool.routes << [  @template1, @template2, @instance1, @modified_instance1, @special1]

    @driver1 = users(:driver1)
    @driver1.current_carpool = @main_carpool 

    @driver2 = users(:driver2)
    @driver2.current_carpool = @main_carpool 

    @passenger1 = users(:passenger1)
    @passenger1.current_carpool = @main_carpool 


  end
end
