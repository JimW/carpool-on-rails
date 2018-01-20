class Event < ApplicationRecord
  # Still need to remove repeating event stuff from here, left over from fullcalendar_engine, setup tests first

  attr_accessor :period, :frequency, :commit_button
  validate :validate_timings
  alias_attribute :starts_at, :starttime
  alias_attribute :ends_at, :endtime

  belongs_to :event_series # Remove XXX

  has_one :event_route, foreign_key: "event_id"#, :dependent => :destroy
  has_one :route, through: :event_route#, :dependent => :destroy
  accepts_nested_attributes_for :event_route
  accepts_nested_attributes_for :route

  RED_COLOR_ID = "8" # Set by Google
  YELLOW_COLOR_ID = "5" # Set by Google
  GREEN_COLOR_ID = "4" # Set by Google
  BLUE_COLOR_ID = "0" # Set by Google

  REPEATS = {
    :no_repeat => "Does not repeat",
    :days      => "Daily",
    :weeks     => "Weekly",
    :months    => "Monthly",
    :years     => "Yearly"
  }
    
  def validate_timings
    if (starttime >= endtime) and !all_day
      errors[:base] << "Start Time must be less than End Time"
    end
  end

  def update_events(events, event)
    events.each do |e|
      begin 
        old_start_time, old_end_time = e.starttime, e.endtime
        e.attributes = event
        if event_series.period.downcase == 'monthly' or event_series.period.downcase == 'yearly'
          new_start_time = make_date_time(e.starttime, old_start_time) 
          new_end_time   = make_date_time(e.starttime, old_end_time, e.endtime)
        else
          new_start_time = make_date_time(e.starttime, old_end_time)
          new_end_time   = make_date_time(e.endtime, old_end_time)
        end
      rescue
        new_start_time = new_end_time = nil
      end
      if new_start_time and new_end_time
        e.starttime, e.endtime = new_start_time, new_end_time
        e.save
      end
    end
    
    event_series.attributes = event
    event_series.save
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
  
  private
  def make_date_time(original_time, difference_time, event_time = nil)   # Can probably be removed, used in update_events, which is used for repeating stuff XXX
    DateTime.parse("#{original_time.hour}:#{original_time.min}:#{original_time.sec}, #{event_time.try(:day) || difference_time.day}-#{difference_time.month}-#{difference_time.year}")
  end 

end