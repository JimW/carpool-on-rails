class RoutesController < ApplicationController

    def permitted_params
      params.permit(:id, :_method, :authenticity_token)
    end

    def get_missing_persons
      # Grab the week their looking at
      @working_week = cookies[:last_viewing_moment] ? cookies[:last_viewing_moment] : "2015 09 12" #YYYY MM DD
      # This will be a Sunday, even if the cal is Mon-Fri

      passenger_anomolies = {}
      start_date = Date.iso8601(@working_week)
      end_date = start_date + 6.days
      all_passengers = current_user.current_carpool.passengers
      routes_within_range = current_user.current_carpool.routes.select {|r| r.starts_at.to_date.between?(start_date, end_date)}

      start_date.upto(end_date) do |date|

        passenger_anomolies[date] = {}
        passengers_for_day = Array.new()
        routes_on_date = routes_within_range.select {|r| r.starts_at.to_date == date}

        routes_on_date.each do |rte|
          rte.passengers.pluck(:first_name).each do |item|
            passengers_for_day << item
          end
        end

        passenger_ride_cnts = passengers_for_day.each_with_object(Hash.new(0)) { |p, counts| counts[p] += 1 }
        # passenger_ride_cnts.each_pair {|key,value| p " ************** #{key} = #{value}"}

        all_passengers.each do |p|
          if (passenger_ride_cnts[p.first_name] < 2)
            passenger_anomolies[date][p.first_name] = passenger_ride_cnts[p.first_name]
          end
        end

      end

      render json: passenger_anomolies.to_json
    end

    def index
      routes = current_user.current_carpool.routes.where(:category => Route.categories[params[:request_type]])

      events = []
      routes.each do |route|
        if route.event
          events << { id: route.event.id,
                      title: route.title_for_calendar_page,
                      description: route.event.description || '',
                      start: route.event.starttime.iso8601,
                      end: route.event.endtime.iso8601,
                      allDay: route.event.all_day,
                      recurring: (route.event.event_series_id) ? true : false
                    }
        end
      end
      render json: events.to_json
    end

    def destroy

      if request.xhr?
        # It's really an event ID from the FullcalendarEngine stuff
        @route = FullcalendarEngine::Event.find(permitted_params[:id]).route
      # else
      #   @route = Route.find(permitted_params[:id])
      end
      #  p "Route:destroy found " + @route.title_for_admin_ui

      if @route.template? && @route.scheduled_instances #.for_today?
        @route.scheduled_instances.each do |route_inst|
          # p "SPECIALZ for " + route_inst.title
          route_inst.category = :special # convert instances to :special, don't just delete them all
          # route_inst.update_columns(category: :special)
          # rte.special! # also this action should not trigger any notifications to users (for the future.. !!!)
          route_inst.save
          session[:last_route_id_edited] = route_inst.id # used to plant a Class to mark the event in the calendar, so the js can highlight the change and scroll to it.
          # what about relationship..
        end
      # else
        # session[:last_route_id_edited] = "" # Last thing edited is gone now.
      end

      @route.destroy

      respond_to do |format|
       format.js
     end

    end

end
