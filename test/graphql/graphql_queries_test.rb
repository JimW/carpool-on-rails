require 'test_helper'

class GraphqlQueryTests < ActionController::TestCase

  def setup
    setup_5_routes_on_main_carpool
  end

  def test_fcEventSources

    context = {
      current_user: @driver1, 
      current_carpool: @main_carpool
    }
    eventSources = CarPoolSchema.execute("{fcEventSources() {}}", context: context, variables: nil)
   
    # fc EventObjects (as formatted by route.as_fullcalendar_event)
    fcInstanceEvent = JSON.parse(eventSources["data"]["fcEventSources"])[0]["events"][0]
    fcModifiedInstanceEvent = JSON.parse(eventSources["data"]["fcEventSources"])[1]["events"][0]
    fcSpecialEvent = JSON.parse(eventSources["data"]["fcEventSources"])[2]["events"][0]

    # Just test that we get back the correct routes
    assert fcInstanceEvent["route_id"] == @instance1.id
    assert fcModifiedInstanceEvent["route_id"] == @modified_instance1.id
    assert fcSpecialEvent["route_id"] == @special1.id

  end

end
