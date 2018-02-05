Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

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
  field :moveFcEventMutation, types.String do
    description "Changes start and endtime of event"
    argument :routeId, !types.Int
    argument :start_time, !types.String
    argument :end_time, !types.String
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      route = Route.find(args[:routeId])
      
      if !route
        raise GraphQL::ExecutionError.new("Route not found")
        # ActiveRecord::RecordNotFound - Couldn't find Route with 'id'=27:
      end

      route.update_times(args[:end_time], args[:start_time])
      return route.as_fullcalendar_event.to_json
    }
  end

  # Wrap this into a real test XXX TTT
  # mutation {
  #   resizeFcEventMutation(
  #     routeId: 3, 
  #     end_time: "2018-01-03 10:30:00" 
  #   ){}
  # }
  # field :resizeFcEventMutation, RouteType do
  field :resizeFcEventMutation, types.String do
    description "Changes endtime of event"
    argument :routeId, !types.Int
    argument :end_time, !types.String
    # argument :start_time, types.String # could maybe make this more generic and use for moveFcEventMutation ??

    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end

      route = Route.find(args[:routeId])
      if !route
        raise GraphQL::ExecutionError.new("Route not found")
      end

      route.update_times(args[:end_time])
      return route.as_fullcalendar_event.to_json
    }
  end

  field :deleteFcEventMutation, RouteType do
    description "Changes endtime of event"
    argument :routeId, !types.Int
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      route = Route.find(args[:routeId]) # be sure using route_id consistenly everywhere and no longer eventid XXX
      if route.template? && route.scheduled_instances #.for_today?
        route.scheduled_instances.each do |route_inst|
          route_inst.category = :special # convert instances to :special, don't just delete them all
          route_inst.save
        end
      end
      route.destroy
    }
  end

  # mutation {
  #   duplicateFcEventMutation(routeId: 49, category: 'special') {
  #   }
  # }
  field :duplicateFcEventMutation, types.String do
    description "duplicates route as templates, instances, or special"
    argument :routeId, !types.Int
    argument :category, !types.String

    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      route = Route.find(args[:routeId])
      newRoute = route.duplicate_as (args[:category]) 
      newRoute.as_fullcalendar_event.to_json
    }
  end
  
  # mutation {
  # revertToTemplateMutation(eventId: 9)
  # }
  field :revertToTemplateMutation, types.String do
    description "duplicates route as templates, instances, or special"
    argument :eventId, !types.Int

    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end

      event_clicked = Event.find(args[:eventId])
      template = event_clicked.route.instance_parent

      new_route = template.deep_clone :include => [:drivers, :passengers, :locations]  
      new_route.instance_parent = template
      new_route.event =  Event.new({
        :starttime => template.event.starttime.iso8601,
        :endtime => template.event.endtime.iso8601
      })
      new_route.category = :instance
      new_route.save!
      
      template.scheduled_instances.destroy(event_clicked.route)
      template.scheduled_instances << new_route
      template.save!

      event_clicked.route.destroy # not deleteing the event for some reason, everything else seems good ??? !!! TEST
      event_clicked.destroy

      # session[:last_route_id_edited] = new_route.id # used to plant a Class to mark the event in the calendar, so the js can highlight the change and scroll to it.
      # cookies.permanent[:last_working_date] = new_route.starts_at.iso8601 # TEST !!!

      # could return a hash with both event and template data to make client life easier !!!
      new_route.as_fullcalendar_event.to_json
    }
  end
  
  # mutation {
    # createRouteMutation(startsAt: "2018-02-26 08:00:00 -0800", endsAt: "2018-02-26 09:00:00 -0800", driver: "", passengers: [""])
    # }
  field :createRouteMutation, types.String do
    description "create new route, as 'special' by defualt, right now atleast.. XXX"

    argument :startsAt, !types.String
    argument :endsAt, !types.String
    argument :location, types.String
    argument :driver, types.String
    argument :passengers, types.String

    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      if ctx[:current_carpool].blank? 
        raise GraphQL::ExecutionError.new("No Carpool specified")
      end

      current_carpool =ctx[:current_carpool]
      routeParams = {
        starts_at: args[:startsAt],
        ends_at: args[:endsAt]
      }

      new_route = Route.new(routeParams)
      new_route.category = :special
      new_route.carpool = current_carpool
      new_route.event =  Event.new({
          :starttime => new_route.starts_at,
          :endtime => new_route.ends_at #starts_at + 30.minutes # Conifiga !!! default_route_time, later it will auto-calc based on locations
      })

      if !args[:location].blank?
        location = Location.find(args[:location])
        new_route.locations << location if location.present?
      end

      if !args[:driver].blank?
        driver = User.find(args[:driver])
        new_route.drivers << driver if driver.present?
      end
     
      if !args[:passengers].blank?
        passengers = User.find(args[:passengers].split(','))
        new_route.passengers << passengers if passengers.present?
      end

      new_route.save!
      # cookies.permanent[:last_working_date] = @route.starts_at.iso8601
      # session[:last_route_id_edited] = @route.id # used to plant a Class to mark the event in the calendar, so the js can highlight the change and scroll to it.
      
      new_route.as_fullcalendar_event.to_json
    }
  end

end
