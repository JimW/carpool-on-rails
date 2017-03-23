class RoutesController < ApplicationController

    def permitted_params
      params.permit(:id, :_method, :authenticity_token)
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
