module FullcalendarEngine

  # Reimplement Fullcalendar stuff ??? I'm not using most of it now

  EventsController.class_eval do  # _______________________ CONTROLLER

     RED_COLOR_ID = "8" # Set by Google
     YELLOW_COLOR_ID = "5" # Set by Google
     GREEN_COLOR_ID = "4" # Set by Google
     BLUE_COLOR_ID = "0" # Set by Google

    # def add_to_google_cal # NOT USED
    #   iron_worker = IronWorkerNG::Client.new
    #   iron_worker.tasks.create('add_to_google_cal', :event => @event)
    # end

    def move
      if @event
        @event.starttime = DateTime.iso8601(params[:day_delta])
        @event.endtime   = DateTime.iso8601(params[:minute_delta])
        @event.all_day   = params[:all_day] == "1" # explicitly handle the values you would like cast to `false` for Rails 5 !!!
        @event.save
        session[:last_route_id_edited] = @event.route.id
        cookies.permanent[:last_working_date] = @event.starttime.iso8601
        # p "_______________________ FullcalendarEngine: move -- event was saved _______________________"
      end
      render :json => {:event => @event, :category => @event.route.category.to_s }
    end

  end

  Event.class_eval do # _______________________ Model __________________________

    # This model is defined within the FullCalendarEngine rails engine and works together
    # with the Fullcalendar JS stuff.  Most of the JS glue has now been rewritten
    # so maybe should just be replaced now.? or made more modular and wrapped back into the Engine.

    # to make it more seamless with the same variables that were initially used within route, !!! figure out if needed
    alias_attribute :starts_at, :starttime
    alias_attribute :ends_at, :endtime

    clear_validators! # FullcalendarEngine was requiring title and description but I'm auto generating those now

    has_one :event_route, foreign_key: "event_id"#, :dependent => :destroy
    has_one :route, through: :event_route#, :dependent => :destroy

    accepts_nested_attributes_for :event_route
    accepts_nested_attributes_for :route
    # How does this trigger the Route Delete oytherwise, what it would do is keep the Event around until the Route deletes, which is what I want...

    after_update :make_route_dirty_if_time_changed # Don't like how coupled this is with Route... !!!
      def make_route_dirty_if_time_changed

        if route && (starttime_changed? || endtime_changed?)
          # route.make_dirty(route.google_calendar_subscribers.pluck(:id)) # should use better way to set this, I'm just passing this so it can be used within route's after_commit
          route.make_dirty(self)
          route.remember_gcal_subscribers 
          route.starts_at = self.starttime # hopefully no longer need these, but keep for now because of activeadmin form dependencies !!!
          route.ends_at = self.endtime
          # Update route.category as necessary
          if !self.new_record? && (route.instance? || route.modified_instance?)
            if route.starts_at.to_date != route.instance_parent.starts_at.to_date
              # p "self.starts_at.wday != self.instance_parent.starts_at.wday ******"
              route.category = :special # Because they dragged it off the same day as the template
              route.route_parent.destroy
            else
              route.category = :modified_instance
            end
          end
          route.save
        end
      end
    # __________

    # For use in Google calendar ids, rfc blah blah, I used this..
    # Just becareful becase Google never deletes events, just marked as cancelled
    # and will fail a later insert with same id, even though it's cancelled.
    def id_hex
      "%05x" % self.id
    end

    # Move to helper
    def time_since_created
      Time.current - created_at
    end

    # Move to route and then to helper !!!
    def description
      route.passenger_list if self.route
      # route.ical_description if self.route
    end

    # Move to Route.rb !!!
    def title
        if self.route
          title_prefix = ""
          title_suffix = ""
          #
          # case self.route.category.to_sym
          #   when :modified_instance
          #     title_prefix = 916.chr + " " # Delta symbol
          #   when :special
          #     title_prefix = 931.chr + " " # Delta symbol
          #     # 8713, 931
          # end

          driver_text = self.route.driver_list
          # special_flag_prefix = self.special? ? 916.chr + " " : "" # Delta symbol
          # special_flag_suffix = self.special? ? "" : ""
          # title_prefix = self.modified_instance? ? 916.chr + " " : "" # Delta symbol
          # title_suffix = self.modified_instance? ? "" : ""
          # title_prefix + self.route.event.starttime.strftime("%-I:%M") + " @ " + self.route.first_location + " : " + driver_text + title_suffix
          # No real need for time embedded in title
          title_prefix + driver_text + " : " + self.route.first_location + title_suffix
        end
    end

    # No longer used, as I'm no longer serving up ics !!! Move to Route.rb
    def to_ics
       cale = Icalendar::Event.new
       cale.dtstart       = starttime
       cale.dtend       = endtime
       cale.summary      = route.ical_title
       cale.description   = route.ical_description
       cale.created       = created_at
       cale.last_modified = updated_at
    #  cale.uid           = id # Don't do this in real life !!! why they say this ?
       cale
     end

     def google_event_flag_color_id
       color_id = nil
       case self.route.category.to_sym
         when :special
           color_id = BLUE_COLOR_ID
         when :modified_instance
           color_id = YELLOW_COLOR_ID
         when :instance
           color_id = GREEN_COLOR_ID
       end
       color_id = (!self.route.drivers.any? || !self.route.passengers.any?) ? RED_COLOR_ID : color_id
       color_id
     end

  end
end
