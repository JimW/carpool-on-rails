
require_dependency("app/models/fullcalendar_engine/event_decorator.rb")

class Route < ApplicationRecord

  include DirtyAssociations
  # include ActiveModel::Dirty

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
  scope :is_special, -> {where(category: "special")}
  scope :is_template, -> {where(category: "template")}
  scope :is_instance, -> {where(category: "instance")}
  # Breaking instance apart so I can show visually the state of the instances
  scope :is_modified_instance, -> {where(category: "instance_modified")}
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

  # monitor_association_changes :scheduled_instances

  # https://github.com/vinsol/fullcalendar-rails-engine/issues/12
  has_one :event_route, inverse_of: :route, :dependent => :destroy
  has_one :event, class_name: "FullcalendarEngine::Event", through: :event_route, :dependent => :destroy
  # "Note that :dependent option is ignored for has_one :through associations."

  accepts_nested_attributes_for :event_route, allow_destroy: true
  accepts_nested_attributes_for :event, allow_destroy: true

  has_many :location_routes,  -> { order 'position' }, inverse_of: :route, :dependent => :destroy
  has_many :locations, through: :location_routes, :after_remove => :make_dirty, :after_add => :make_dirty
  # monitor_association_changes :locations

  accepts_nested_attributes_for :location_routes, allow_destroy: true
  accepts_nested_attributes_for :locations, allow_destroy: true

  has_many :is_driver_users, -> {is_driver}, :class_name => 'RouteUser', inverse_of: :route, :dependent => :destroy
  has_many :drivers, -> { all_can_drive }, :class_name => 'User', :through => :is_driver_users, :source => :user#, :after_add => :after_driver_add, :after_remove => :after_driver_remove
  # monitor_association_changes :drivers

  has_many :is_passenger_users, -> {is_passenger}, :class_name => 'RouteUser', inverse_of: :route, :dependent => :destroy
  has_many :passengers, -> { distinct }, :class_name => 'User', :through => :is_passenger_users, :source => :user#, :before_add => :remember_previous_subscribers, :before_remove => :remember_previous_subscribers
  # monitor_association_changes :passengers

  has_many :is_routine_driver_users, -> {is_driver}, :class_name => 'RouteUser', inverse_of: :route, :dependent => :destroy
  has_many :routine_drivers, -> {all_can_drive}, :class_name => 'User', :through => :is_routine_driver_users, :source => :user, :dependent => :destroy#, :after_add => :make_dirty, :after_remove => :make_dirty
  # monitor_association_changes :routine_drivers

  has_many :is_routine_passenger_users,  -> {is_passenger}, :class_name => 'RouteUser', inverse_of: :route, :dependent => :destroy
  has_many :routine_passengers, -> { distinct }, :class_name => 'User', :through => :is_routine_passenger_users, :source => :user, :dependent => :destroy#, :after_add => :make_dirty, :after_remove => :make_dirty
  # monitor_association_changes :routine_passengers

  has_many :route_users, :class_name => 'RouteUser', inverse_of: :route
  has_many :google_calendar_subscribers, -> { all_google_calendar_subscribers }, :class_name => 'User', :through => :route_users, :source => :user, :after_remove => :make_dirty, :after_add => :make_dirty
  accepts_nested_attributes_for :route_users

  # before_validation
  before_save :set_as_modified_instance#, :set_as_special_if_start_changes
    # TODO  Integrate some variable watching, for visually showing people what changed, but also for rollback.
    def set_as_modified_instance

      # update Timestamp is trigerring self.changed? !!! Not good when creating an instance?
      # if self.changed_attributes.

      # DirtyAssociations module included for use with my has_may associations, to help .changed? work correctly
      if !self.new_record? && self.changed? # does this apply just to my has_manys? why does define_attribute_method not work ???
        # p "This is what changed: " + self.changes.inspect.humanize

        # if (self.changes.count == 1) && self.updated_at_changed?
        #   p "______________ Just the updated_at changed for " + self.title_for_admin_ui
        # end

        if self.instance? && !self.category_changed?
          self.category = :modified_instance
          p "self.category = :modified_instance"
        end
        # if self.template? && (self.scheduled_instances.any?)
        #   # self.scheduled_instances.first.category = :modified_instance # what is this first stuff..., needs to be has_one !!!
        #   p "self.scheduled_instances.first.category = :modified_instance"
        # end

      end
    end

  def remember_gcal_subscribers # in case their calendars need to get deleted after they're removed from route after_commit
    self.subscriber_ids_previous = google_calendar_subscribers.pluck(:id)
  end

  before_destroy :cancel_google_event, prepend: true #if (rte.category.to_sym != :template)  #, on: [:destroy]
    def cancel_google_event
      # Should use a status flag here !!! because maybe the API will fail and need a way to know that things are out of sync

      if (category.to_sym != :template)
        # Move some of this into Event class  !!!
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

  def self.of_category(cat)
    @routes = Route.where(:category => Route.categories[cat])    
  end

  def self.get_events(cat)
    # p "self.get_events(cat) ____________________________________________________________________________________________"
    @routes = Route.where(:category => Route.categories[cat])
    events = []
    @routes.each do |route|
      if route.event
        events << { id: route.event.id,
                    title: route.event.title,
                    description: route.event.description || '',
                    start: route.event.starttime.iso8601,
                    end: route.event.endtime.iso8601,
                    allDay: route.event.all_day,
                    recurring: (route.event.event_series_id) ? true : false
                  }
      end
    end
    events.to_json
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
