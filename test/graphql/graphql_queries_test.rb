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

  # mutation {
    # createRouteMutation(startsAt: "2018-02-26 08:00:00 -0800", endsAt: "2018-02-26 09:00:00 -0800", driver: "", passengers: [""])
    # }
  def test_createRoute

    context = {
      current_user: @driver1, 
      current_carpool: @main_carpool
    }

    queryVars = {
      startsAt: "2018-01-26 10:00:00 -0800",
      endsAt: "2018-01-26 11:00:00 -0800",
      driver: "", 
      passengers: [""]
    }.stringify_keys

    query = <<-GRAPHQL
      mutation {
        createRouteMutation(
          startsAt: "2018-02-26 08:00:00 -0800",
          endsAt: "2018-02-26 09:00:00 -0800",
          driver: "",
          passengers: ""
        )
      }
    GRAPHQL

    # working graphiql
    # createRouteMutation(startsAt: "2018-02-26 08:00:00 -0800", endsAt: "2018-02-26 09:00:00 -0800", driver: "", passengers: "")

    # Why not working: ???, Can't find qVars being sent in, bug???
    # newRouteResponse = CarPoolSchema.execute("mutation {createRouteMutation} ", context: context, variables: queryVars))

    newRouteResponse = CarPoolSchema.execute(query, context: context, variables: nil)
    newRoute = JSON.parse(newRouteResponse["data"]["createRouteMutation"])
    # NOTE: newRoute is a fullCalendar formated events

    assert newRoute['start'] == '2018-02-26T08:00:00-08:00'  

    # Try with a driver and passenger
    queryVars = {
      startsAt: "2018-01-26 10:00:00 -0800",
      endsAt: "2018-01-26 11:00:00 -0800",
      driver: "#{@driver1.id.to_s}",
      passengers: ["#{@passenger1.id.to_s}"]
    }.stringify_keys
    newRouteResponse = CarPoolSchema.execute(query, context: context, variables: nil)
    newRoute = JSON.parse(newRouteResponse["data"]["createRouteMutation"])

    assert newRoute['start'] == '2018-02-26T08:00:00-08:00' 

  end


  # // This works: SAVE for TEST
  # // var newRouteFeedData = "{\"activeDrivers\":[{\"value\":1,\"text\":\"BigGuy\"},{\"value\":2,\"text\":\"JimDriver\"}],\"activePassengers\":[{\"value\":3,\"text\":\"JunkPassenger\"}]}"


    #   mutation {
  #   moveFcEventMutation(
  #     routeId: 3, 
  #     start_time: "2018-01-03 10:00:00" 
  #     end_time: "2018-01-03 10:30:00" 
  #   ){
  #     id
  #     title
  #     passenger_cnt
  #     category
  #     starts_at
  #     ends_at
  #   }
  # }


    # Wrap this into a real test XXX TTT
  # mutation {
  #   resizeFcEventMutation(
  #     routeId: 3, 
  #     end_time: "2018-01-03 10:30:00" 
  #   ){}
  # }

    # mutation {
  #   duplicateFcEventMutation(routeId: 49, category: 'special') {
  #   }
  # }

    # mutation {
  # revertToTemplateMutation(eventId: 9)
  # }

    # mutation {
    # createRouteMutation(startsAt: "2018-02-26 08:00:00 -0800", endsAt: "2018-02-26 09:00:00 -0800", driver: "", passengers: [""])
  # }
  
  # query {
  #   missingPassengers(startDate: "") {
  #   }
  # }

  # {
    #   newRouteFeedData
    # }
end
