
class Route < ApplicationRecord

  include DirtyAssociations
  # include ActiveModel::Dirty
  validates :starts_at, :ends_at, presence: true

  # http://www.mariocarrion.com/2015/07/01/dirty-associations.html
  # https://github.com/krisleech/wisper
  # https://blog.engineyard.com/2014/keeping-your-rails-controllers-dry-with-services
  enum category: {
                  template: 0,
                  instance: 1,          # instance of template
                  modified_instance: 2, # instance of template with modified time, but same day
                  special: 3            # a typical route, not associated with an instance
               #, instance_modified: 3,
               #  instance_cancelled: 4,
               #  instance_delayed: 5 } #, _prefix: :xyz
  }

  attr_accessor :deleted_user_ids, :added_user_ids, :updated_user_ids, :subscriber_ids_previous, :subscriber_ids_current

  def after_initialize
    subscriber_ids_previous = []
    subscriber_ids_current = []
    deleted_user_ids = []
    added_user_ids = []
    updated_user_ids = []
  end

  # TODO
  # all these should be determined by relationship, not an additional variable I have to manage
  scope :of_category, -> (category) { where category: category }
  # Maybe replace below category scopes with one above
  scope :is_special, -> {where(category: "special")}
  scope :is_template, -> {where(category: "template")}
  scope :is_instance, -> {where(category: "instance")}
  # Breaking instance apart so I can show visually the state of the instances
  scope :is_modified_instance, -> {where(category: "modified_instance")}
  scope :assignments_x, -> user_id {   # No space between "->" and "("
  #   includes(:user_assignments).where('user_assignments.id == ' + user_id.to_s)
    assignments.for_user(user_id )
  }

  just_define_datetime_picker :starts_at
  just_define_datetime_picker :ends_at

  # http://stackoverflow.com/questions/25231774/rails-ruby-self-referential-association-using-dependent-destroy-causing-dupli
  # http://stackoverflow.com/questions/28072307/self-referential-association-with-attributes-in-activerecord

  belongs_to :carpool

  # inverse_of: :route, # never want to use inverse_of in an self referential..
  has_one :route_parent, :class_name => "RouteInstance", foreign_key: 'instance_id', :dependent => :destroy
  has_one :instance_parent, -> { is_template }, class_name: "Route", :source => :route, through: :route_parent, :dependent => :destroy

  accepts_nested_attributes_for :route_parent, allow_destroy: true
  accepts_nested_attributes_for :instance_parent, allow_destroy: true

  has_many :route_instances, :class_name => "RouteInstance", foreign_key: 'route_id', :dependent => :destroy
  has_many :scheduled_instances, class_name: "Route", :source => :instance, through: :route_instances, :dependent => :destroy
  accepts_nested_attributes_for :route_instances, allow_destroy: true
  accepts_nested_attributes_for :scheduled_instances, allow_destroy: true

  # Not currently used/tested !!!
  has_many :modified_route_instances, -> { is_modified }, inverse_of: :route, :class_name => "RouteInstance", foreign_key: 'route_id', :dependent => :destroy
  has_many :modified_scheduled_instances, class_name: "Route", :source => :instance, through: :modified_route_instances, :dependent => :destroy

  has_one :event_route, inverse_of: :route, :dependent => :destroy
  has_one :event, class_name: "Event", through: :event_route, :dependent => :destroy
  # "Note that :dependent option is ignored for has_one :through associations."

  accepts_nested_attributes_for :event_route, allow_destroy: true
  accepts_nested_attributes_for :event, allow_destroy: true

  has_many :location_routes,  -> { order 'position' }, inverse_of: :route, :dependent => :destroy
  has_many :locations, through: :location_routes, :after_remove => :make_dirty, :after_add => :make_dirty

  accepts_nested_attributes_for :location_routes, allow_destroy: true
  accepts_nested_attributes_for :locations, allow_destroy: true

  has_many :is_driver_users, -> {is_driver}, :class_name => 'RouteUser', inverse_of: :route, :dependent => :destroy
  has_many :drivers, -> { all_can_drive }, :class_name => 'User', :through => :is_driver_users, :source => :user, :after_add => :make_dirty, :after_remove => :make_dirty

  has_many :is_passenger_users, -> {is_passenger}, :class_name => 'RouteUser', inverse_of: :route, :dependent => :destroy
  has_many :passengers, -> { distinct }, :class_name => 'User', :through => :is_passenger_users, :source => :user, :after_add => :make_dirty, :after_remove => :make_dirty#, :before_add => :remember_previous_subscribers, :before_remove => :remember_previous_subscribers

  has_many :is_routine_driver_users, -> {is_driver}, :class_name => 'RouteUser', inverse_of: :route, :dependent => :destroy
  has_many :routine_drivers, -> {all_can_drive}, :class_name => 'User', :through => :is_routine_driver_users, :source => :user, :dependent => :destroy#, :after_add => :make_dirty, :after_remove => :make_dirty

  has_many :is_routine_passenger_users,  -> {is_passenger}, :class_name => 'RouteUser', inverse_of: :route, :dependent => :destroy
  has_many :routine_passengers, -> { distinct }, :class_name => 'User', :through => :is_routine_passenger_users, :source => :user, :dependent => :destroy#, :after_add => :make_dirty, :after_remove => :make_dirty

  has_many :route_users, :class_name => 'RouteUser', inverse_of: :route
  has_many :google_calendar_subscribers, -> { all_google_calendar_subscribers }, :class_name => 'User', :through => :route_users, :source => :user, :after_remove => :make_dirty, :after_add => :make_dirty
  accepts_nested_attributes_for :route_users

  before_update :set_as_modified_instance#, :set_as_special_if_start_changes ??
    # TODO  Integrate some variable watching, for visually showing people what changed, but also for rollback.
    def set_as_modified_instance

      # if self.saved_change_to_category?(from: 'template', to: 'instance') # the new 5.1 way
      #   # Happens after dup of the original template while creating an instance, causes this 2nd update here so should change probably change how I create an instance
      # end

      # Note: DirtyAssociations module cia make_dirty within has_may definitions, helps .changed? reflect changes within drivers, passengers, and location associations
      # associationDataModified = (self.locations.any?(&:changed?) || self.passengers.any?(&:changed?) || self.drivers.any?(&:changed?) )
      #  should not happen because I'm only changing tne relationship data, not the actual data of those relationships, but still
      if (self.changed?)# || associationDataModified)
        if self.instance? && !self.category_changed? && !self.carpool_id_changed? # last one happens as a byproduct of testing with fixtures, don't plan on dragging routes between carpools, but who knows..
          # p "set_as_modified_instance ____________________________________ self.category = :modified_instance"
          # binding.pry
          self.category = :modified_instance
        end
      end
    end

  before_update :make_route_dirty_if_time_changed
    def make_route_dirty_if_time_changed
      # p "______ make_route_dirty_if_time_changed "
      # if (saved_change_to_starts_at? || saved_change_to_ends_at?)
      if (starts_at_changed? || ends_at_changed?)
        # route.make_dirty(route.google_calendar_subscribers.pluck(:id)) # should use better way to set this, I'm just passing this so it can be used within route's after_commit
        # route.make_dirty(self)
        remember_gcal_subscribers 
        # route.starts_at = self.starttime # hopefully no longer need these, but keep for now because of activeadmin form dependencies !!!
        # route.ends_at = self.endtime
        # Update route.category as necessary
        if (!self.new_record?) && (self.instance? || self.modified_instance?)
          if self.starts_at.to_date != self.instance_parent.starts_at.to_date
            # p " self.starts_at.to_date != self.instance_parent.starts_at.to_date ******"
            self.category = :special # Because they dragged it off the same day as the template
            # p "make_route_dirty_if_time_changed ____________________________________ self.category = :special"
            self.instance_parent.scheduled_instances.delete(self)
          else
            # binding.pry
            self.category = :modified_instance
            # p "make_route_dirty_if_time_changed ____________________________________ self.category = :modified_instance"
          end
        end
      end
    end

  def remember_gcal_subscribers # in case their calendars need to get deleted after they're removed from route after_commit
    self.subscriber_ids_previous = google_calendar_subscribers.pluck(:id)
  end

  before_destroy :cancel_google_event, prepend: true #if (rte.category.to_sym != :template)  #, on: [:destroy]
    def cancel_google_event
      # Should use a status flag here !!! because maybe the API will fail and need a way to know that things are out of sync
      
      # During revert, I'm concerned that 2 asych events, one for delete and another for the new one, could get mixed up in sequence during actual execution and fail because of a duplicate event error from google
      # should really make the google ID be less tied to event/route id, store it in the db along with a new sync_status flag and solve 2 issues.  But then we won't be able to actually delete it here.
      # This situation could potentially be helped out by some apollo-link middleware, once that evolves more maybe ??? XXX

      if (category.to_sym != :template)
        event_data = {
          location: first_stop_street_city,
          start_iso8601: event.starttime.iso8601,
          end_iso8601: event.endtime.iso8601,
          description: ical_description,
          summary: event.title,
          id: event.id_hex,
          color_id: event.google_event_flag_color_id
        }
        # Delete event from carpool calendar
        carpool_cal_id = carpool.google_calendar_id
        GcalCancelEventJob.perform_later(carpool_cal_id, event_data) if !carpool_cal_id.blank?

        # Delete event from each subscriber's personal calendar
        google_calendar_subscribers.each do |user|
          gcal_id = user.personal_gcal_id_for(carpool.organization.id)
          GcalCancelEventJob.perform_later(gcal_id, event_data) if !gcal_id.blank?
        end
      end

      event.destroy
    end

  after_commit :create_google_event, on: [:create]
    def create_google_event
      GcalRouteCreateEventsJob.perform_later self # the job will figure out if calendars are even enabled
    end

  after_commit :update_google_event, on: [:update]
    def update_google_event
      if (self.category.to_sym != :template)
        GcalRouteUpdateEventsJob.perform_later(self, self.subscriber_ids_previous) 
      end
    end

  def update_times(e_time, s_time = nil)
    self.remember_gcal_subscribers 

    if s_time # optional param
      event.starttime = s_time
      self.starts_at = s_time
    end

    event.endtime   = e_time
    self.ends_at = e_time
    
    event.all_day = false # not sure this is necessary, what if I want to move templates
    
    event.save!
    # all this stuff was moved from Event Controller so it could be still done but via graphql: (just keeping it around for a while)
    # if (instance? || modified_instance?)
    #   if starts_at.to_date != self.instance_parent.starts_at.to_date # event was dragged to new date
    #     p "self.starts_at.wday != self.instance_parent.starts_at.wday ******"
    #     self.category = :special # Because they dragged it off the same day as the template
    #     # use self.category because it's an undocumented reserved word (3 hours later..)

    #     self.route_parent.destroy
    #   else
    #     p "SETTING: category = :modified_instance"

    #     self.category = :modified_instance
    #   end
    # end
    self.save!
    # # ToReImplement via graphql or maybe in Apollo Link? XXX
    #   # session[:last_route_id_edited] = @event.route.id
    #   # cookies.permanent[:last_working_date] = @event.starttime.iso8601
    #   # route.make_dirty(route)
  end
  
  def self.batch_update_calendars_for(route_ids)
    # makes this a batch request !!! (it's called from User when it's meta changes)
    route_ids.each do |id|
      route = Route.find(id)
      route.remember_gcal_subscribers # yuck !!! this whole mechanism.. 
      route.make_dirty(route.google_calendar_subscribers.pluck(:id))
      route.save
    end unless route_ids.nil?
  end

  def first_stop_street_city
    result = ""
    if locations.any?
      if locations.first.street?
        result += locations.first.street
      end
      if locations.first.city?
        result += (locations.first.street? && locations.first.city?) ? ", " : ""
        result += locations.first.city
      end
    end
    result
  end

  # All this event fullcalendar mapping stuff belongs in Reactland, seems
  def self.as_fullcalendar_events
    all.includes(:scheduled_instances).map(&:as_fullcalendar_event)
  end

  def as_fullcalendar_event
    eventDataForFullcalendar = { 
      id: event.id,
      title: event.title,
      description: event.description || '',
      start: event.starttime.iso8601,
      end: event.endtime.iso8601,
      allDay: event.all_day,
      recurring: (event.event_series_id) ? true : false,
      category: category.to_s,
      has_children: (self.scheduled_instances.any?) ? true: false,
      route_id: id,
      child_id: (self.scheduled_instances.any?) ?  self.scheduled_instances.first.event.id : '',
      parent_template_id: (self.instance_parent) ?  self.instance_parent.event.id : ''
    }
    return eventDataForFullcalendar
  end
  
  def duplicate_as (cat) 

    # p "duplicate_as: " + cat.to_s + "______________________________________________________"

    new_route = self.deep_clone :include => [:drivers, :passengers, :locations]
    new_route.event =  Event.new({
        :starttime => event.starttime.iso8601,
        :endtime => event.endtime.iso8601
    })
    new_route.event.all_day = false # move this to client

    case cat.to_s
    when "template" # Transform current route to an instance, new_route becomes a template parenting this instance
      new_route.category = :template
      new_route.event.all_day = true  # so it shows at top in Fullcalendar, move this to event code !!! ?, no, move to js..
      # Turn original into an instance
      self.category = :instance
      self.instance_parent = new_route
      new_route.scheduled_instances << self
      # event_clicked.save
      # event_clicked.route.modified = false
    when "instance"
      if !scheduled_instances.any? # only one instance allowed
        new_route.category = :instance
        self.scheduled_instances << new_route
      end
    when "special"
      new_route.category = :special
      # Might have to not copy the passengers and drivers once there becomes
      # logic validations (like no passenger in 2 cars at same time, etc)
      # Maybe a way to turn on and off validations? so the admin can mess around freely? ???
    end

    self.save
    new_route.save
    new_route
    # Not sure how to deal with this yet in graphql
    # if dup_type.to_s == "make_instance"
    #   session[:last_route_id_edited] = event_clicked.route.id # keep focus on the instance
    #   # p "session[:last_route_id_edited] = " + session[:last_route_id_edited] + " and should = " + event_clicked.route.id.to_s
    # else
    #   session[:last_route_id_edited] = new_route.id
    # end

  end

  def display_driver
    driver_txt = drivers.any? ? drivers.first.first_name : " DRIVER ?"
    starts_at.strftime("%-I:%M") + " @ " + first_location
  end

  def title
    read_attribute(:title) || title_for_admin_ui
  end

  def title_for_calendar_page
    driver_list + " " + self.event.starttime.strftime("%-I:%M") + " @" + self.first_location + " " + passenger_list_first_name
  end

  def title_for_admin_ui
    if (self.event)
      case category.to_sym
        when :template
          self.event.starttime.strftime("%a %-I:%M") + " @ " + self.first_location
        when :instance
          self.event.starttime.strftime("%a %e %b %-I:%M") + " @ " + self.first_location
        when :modified_instance
          self.event.starttime.strftime("%a %e %b %-I:%M") + " @ " + self.first_location
        when :special
          self.event.starttime.strftime("%a %-I:%M") + " @ " + self.first_location
      end
    else
      "Route's Event Corrupt"
    end
  end

  def first_last_location
    # ordered_locations = self.locations.ordered
    case
    when self.locations.count > 1
      self.locations.first.short_name + " -> " + self.locations.last.short_name
    when self.locations.count == 1
      self.locations.first.short_name + " -> ?"
    when self.locations.count == 0
      "LOCATION ?"
    end
  end

  def first_location
    self.locations.any? ?  self.locations.first.short_name : "LOCATION ?"
  end

  def passenger_list_first_name
    # This is used in the Calendar page, so keep everything condensed so it'll fit on one line
    if self.passengers.any?
      "w/ " + self.passengers.map{|p| p.first_name}.to_sentence(:last_word_connector => ' ', :words_connector => ' ')
    else
      "PASSENGERS ?"
    end  end

  def passenger_list
    if self.passengers.any?
      "w/ " + self.passengers.map{|p| p.short_name}.to_sentence(:last_word_connector => ' ', :words_connector => ' ')
    else
      "PASSENGERS ?"
    end
  end

  # Make sure this is never in a public calendar !!!
  def route_passenger_detail
    passenger_txt = ""
    if self.passengers.any?
      passenger_txt = "_________ " + self.passengers.count.to_s + " Passengers: _________\n" + self.passengers.map { |p| p.full_name_with_mobile_phone }.join("\n")
    else
      passenger_txt = "No Passengers!\n"
    end
    passenger_txt
  end

  def route_driver_detail
    driver_txt = ""
    if self.drivers.any?
      driver_txt = "Driver(s):\n" + self.drivers.map { |d| d.full_name_with_mobile_phone }.join("\n")
    else
      driver_txt = "No Driver!\n"
    end
    driver_txt
  end

  def ical_title
    self.event.title
  end

  def ical_description
    route_driver_detail + "\n" + route_passenger_detail
  end

  def driver_list

    # title_prefix = ""
    # title_suffix = ""
    #
    # case category.to_sym
    #   when :modified_instance
    #     title_prefix = 916.chr + " " # Delta symbol
    #   when :special
    #     title_prefix = 931.chr + " " # Delta symbol
    #     # 8713, 931
    # end

    self.drivers.any? ? self.drivers.first.first_name : " DRIVER ?"
    # special_flag_prefix = self.special? ? 916.chr + " " : "" # Delta symbol
    # special_flag_suffix = self.special? ? "" : ""
    # title_prefix = self.modified_instance? ? 916.chr + " " : "" # Delta symbol
    # title_suffix = self.modified_instance? ? "" : ""
    # title_prefix + self.event.starttime.strftime("%-I:%M") + " @ " + self.first_location + " : " + driver_text + title_suffix
  end

  def to_google_event
    # event_google__event(loc, starttime_iso8601, endtime_iso8601, desc, summary, id, color_id) !!! send in the static data
    google_event_to_return = nil

    if !event.nil? # make sure event is not deleted first..
      location = first_stop_street_city
      start_eventDateTime = Google::Apis::CalendarV3::EventDateTime.new(date_time: event.starttime.iso8601)
      end_eventDateTime = Google::Apis::CalendarV3::EventDateTime.new(date_time: event.endtime.iso8601)

      description = ical_description # be careful if I rip out the ical code, rename it at least
      summary = event.title
      id = event.id_hex
      color_id = event.google_event_flag_color_id

      google_event_to_return = Google::Apis::CalendarV3::Event.new( id: id,
                                                          summary: summary,
                                                          description: description,
                                                          location: location,
                                                          start: start_eventDateTime,
                                                          end: end_eventDateTime,
                                                          guests_can_modify: false,
                                                          guests_can_see_other_guests: false,
                                                          guests_can_invite_others: false,
                                                          locked: true, # change? !!!
                                                          color_id: color_id
                                                        )
                                                          # colorRgbFormat: true,
    end

    p "to_google_event _____________________________ could not find event, maybe already deleted.?!?!_____________________________" if google_event_to_return.nil?

    return google_event_to_return
  end

end
