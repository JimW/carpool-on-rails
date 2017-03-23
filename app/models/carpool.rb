class Carpool < ActiveRecord::Base
  resourcify

  validates :title, :title_short, :organization, presence: true

  belongs_to :organization
  has_many :routes

  has_many :carpool_locations, inverse_of: :carpool, :dependent => :destroy
  has_many :locations, :through => :carpool_locations
  accepts_nested_attributes_for :carpool_locations, allow_destroy: true
  accepts_nested_attributes_for :locations, allow_destroy: true 

  has_many :driving_members, -> {is_driver}, :class_name => 'CarpoolUser', inverse_of: :carpool, :dependent => :destroy
  has_many :drivers, -> { all_can_drive }, :class_name => 'User', :through => :driving_members, :source => :user#, :after_add => :make_dirty, :after_remove => :make_dirty
  accepts_nested_attributes_for :driving_members, allow_destroy: true
  accepts_nested_attributes_for :drivers, allow_destroy: true

  has_many :passenger_members, -> {is_passenger}, :class_name => 'CarpoolUser', inverse_of: :carpool, :dependent => :destroy
  has_many :passengers, -> { all_can_not_drive }, :class_name => 'User', :through => :passenger_members, :source => :user#, :after_add => :make_dirty, :after_remove => :make_dirty
  accepts_nested_attributes_for :passenger_members, allow_destroy: true
  accepts_nested_attributes_for :passengers, allow_destroy: true

  has_many :unique_members, -> {uniq}, :class_name => 'CarpoolUser', inverse_of: :carpool, :dependent => :destroy
  has_many :users, :class_name => 'User', :through => :unique_members, :source => :user
  has_many :google_calendar_subscribers, -> {all_google_calendar_subscribers}, :class_name => 'User', :through => :unique_members, :source => :user

  # before_destroy :create_destroy_carpool_google_calendar
  #   def destroy_carpool_google_calendar
  #     # Need to isolate parameters from (should really move all this out of destroy and place into some kind of CANCEL state !!!)
  #     GcalCarpoolCreateDestroyCalendarsJob.perform_later self if self.publish_to_gcal
  #   end

  after_commit :create_destroy_carpool_google_calendar, on: [:update], :if => Proc.new { |record| record.previous_changes.key?(:publish_to_gcal) }
    def create_destroy_carpool_google_calendar
  #    p "create_destroy_carpool_google_calendar: they toggled the carpool gcal for " + self.title + " __________________________"
      GcalCarpoolCreateDestroyCalendarsJob.perform_later self
    end

  # before_destroy :reset_users_current_carpools
    def reset_users_current_carpools
      users.each do |user|
        user.reset_current_carpool
      end unless users.empty?
    end

  def manager_emails
    emails = []
    User.with_role(:manager, self).each { |user|
      emails << user.email unless user.email.blank?
    }
    emails
  end

  def manager_names_and_emails
    email_str = ""
    User.with_role(:manager, self).each { |user|
      email_str += "\n " if !email_str.blank?
      email_str += user.email
    }
    email_str
  end

  # TBD !!!
  def missing_routes(date_range)
    missing_routes = []
    passengers.each do |p|
      # get dates for current week
      # check that each date has 2 routes for passenger
      p "user.full_name = " + full_name
    end unless passengers.empty?
    return missing_routes
  end

  def routes_for_day(user, date)
    routes = []
    return routes
  end

end
