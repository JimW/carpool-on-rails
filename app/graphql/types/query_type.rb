Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
  # Add root-level fields here.
  # They will be entry points for queries on your schema.
  
  field :viewer do
    type UserType
    description "Current user"
    resolve ->(obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      ctx[:current_user]
    }
  end

  field :carpool do
    type CarpoolType
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      argument :id, !types.ID      
      Carpool.find(args[:id])
    }
  end

  field :user do
    type UserType
    argument :id, !types.ID
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      User.find(args[:id])
    }
  end

  field :route do
    type RouteType
    argument :id, !types.Int
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      Route.find(args[:id])
    }
  end

  field :location do
    type LocationType
    argument :id, !types.Int
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      Location.find(args[:id])
    }
  end

  field :allUsers, types[UserType] do
    resolve -> (obj, args, ctx) { 
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      User.all 
    }
  end

  field :currentUser do
    type UserType 
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      ctx[:current_user]
    }
  end

  field :fcEventSources do
    type types.String 
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      cp = ctx[:current_carpool]
      eventSources = [
        {events: cp.routes.of_category("instance").as_fullcalendar_events()},
        {events: cp.routes.of_category("modified_instance").as_fullcalendar_events()},
        {events: cp.routes.of_category("special").as_fullcalendar_events()},
      ]
      eventSources.to_json
    }
  end

  field :fcEventSourcesRoutes do
    type types.String 
    resolve -> (obj, args, ctx) {
      if ctx[:current_user].blank?
        raise GraphQL::ExecutionError.new("Authentication required")
      end
      cp = ctx[:current_carpool]
      eventSources = [
        {events: cp.routes.of_category("instance").as_fullcalendar_events()},
        {events: cp.routes.of_category("modified_instance").as_fullcalendar_events()},
        {events: cp.routes.of_category("special").as_fullcalendar_events()},
        {events: cp.routes.of_category("template").as_fullcalendar_events()}
      ]
      eventSources.to_json
    }
  end

  
  field :missingPassengers do
      type types.String 
      argument :startDate, !types.String
      # argument :endDate, !types.String

      resolve -> (obj, args, ctx) {
        if ctx[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end
        
        events = []
        cp = ctx[:current_carpool]
        missing_passengers_by_date = cp.get_missing_persons(args[:startDate]) # assumes +6 days for end
        # p "missing_passengers_by_date = " + missing_passengers_by_date
        # missing_passengers_by_date = cp.get_missing_persons(args[:startDate], args[:endDate])
  
        missing_passengers_by_date.each_pair do |date, missing_who_cnt|
  
          missing_who_cnt.keys.each do |passenger| 
            events << { id: -1,
                title: passenger,
                description: '',
                start: date.iso8601,
                end: date.iso8601,
                allDay: true,
                recurring: false,
                category: 'missing_person',
                className: '',
                has_children: false,
                route_id: 0,
                child_id: ''
              } if !passenger.nil?
          end
  
        end
  
        events.to_json

      }
    end

    
    field :newRouteFeedData do # use same naming prefix as matching form partial, newRouteFormDataFeeder
      type types.String 
      resolve -> (obj, args, ctx) {
        if ctx[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end
        cp = ctx[:current_carpool]
        locations_data = cp.locations.all.inject([]) { |accum, o| accum << {value: o.id, text: o.title} }
        active_drivers_data = cp.active_drivers.inject([]) { |accum, o| accum << {value: o.id, text: o.full_name} }
        active_passengers_data = cp.active_passengers.inject([]) { |accum, o| accum << {value: o.id, text: o.full_name} }

        response = {
          activeDrivers: active_drivers_data,
          activePassengers: active_passengers_data,
          locations: locations_data,
        }.to_json
        
        return response
      }
    end

  end

  # Following is for reference for coversion to React, helps think about state variables that need to be managed, now on the client:

  # @calendar_all_day_mode = cookies[:calendar_all_day_mode] ? cookies[:calendar_all_day_mode] : 'routines'
  # # p "@calendar_all_day_mode = " + @calendar_all_day_mode
  # @working_week = cookies[:last_viewing_moment] ? cookies[:last_viewing_moment] : "2015 09 12" #YYYY MM DD
  # events = []

  # # XXX
  # #  Need to move all this state logic into the client, within React, but ensure necessary data is availble within graphql data queries
  # # Missing logic needs to be moved into JS within RouteCAlendar jsx
  # # @working_week needs to be a graphql param, , could work off local data is using ApolloLink.
  # # How /Should I, respect ransack shit, seems no, if I just provide listing option via React spreadsheet/filter type plugin

  # # Still need to totally strip out all 

  # if (params[:request_type] == "template") && (@calendar_all_day_mode == 'missing_persons')
  #   # We're hijacking the request for template data here, because now we're overloading the ALLDAY spot in the calendar to also show missing passengers
  #   # So lets feed it one big fat fake event that contains all the names of the missing passengers for the day!
  #   missing_persons_by_date = current_user.current_carpool.get_missing_persons(@working_week)

  #   missing_persons_by_date.each_pair do |date, missing_who_cnt|

  #     missing_who_cnt.keys.each do |passenger| 
  #       events << { id: -1,
  #           title: passenger,
  #           description: '',
  #           start: date.iso8601,
  #           end: date.iso8601,
  #           allDay: true,
  #           recurring: false,
  #           category: 'missing_person',
  #           className: '',
  #           has_children: false,
  #           route_id: 0,
  #           child_id: ''
  #         } if !passenger.nil?
  #     end

  #   end

  # else    
  #     # Use the Ransack query from Activeadmin
  #   params[:q] = session[:search]
  #   @q = current_user.current_carpool.routes.ransack(params[:q])#.include(:)
  #   # refine by whatever calendar data sources the fullCalendar wants via :request_type (and now it wants the id..)
  #   # modifiedType = if params[:request_type]
  #   routes = @q.result.where(:category => Route.categories[params[:request_type]])
  #   # p "session[:last_route_id_edited] = " + session[:last_route_id_edited].to_s
  #   routes.each do |route|
  #     if route.event
  #       @classNames = []
  #       @classNames << "CurrentEvent" if (route.id == session[:last_route_id_edited].to_i)

  #       # if route.is_template?
  #       #   start_date = route.event.starttime.wday # Need to translate this into current selected week's actual date
  #       #   end_date = route.event.endtime.wday
  #       # else
  #       #   start_date = route.event.starttime.iso8601
  #       #   end_date = route.event.endtime.iso8601
  #       # end

  #       events << { id: route.event.id,
  #                   title: route.event.title,
  #                   description: route.event.description || '',
  #                   start: route.event.starttime.iso8601,
  #                   end: route.event.endtime.iso8601,
  #                   allDay: route.event.all_day,
  #                   recurring: (route.event.event_series_id) ? true : false,
  #                   category: route.category.to_s,
  #                   className: @classNames.join(","),
  #                   has_children: route.scheduled_instances.any?,
  #                   route_id: route.id,
  #                   child_id: (route.scheduled_instances.any?) ?  route.scheduled_instances.first.event.id : ''
  #                 }
  #     end # if
  #   end # do
  # end # else

  # render json: events.to_json


