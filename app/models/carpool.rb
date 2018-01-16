class Carpool < ApplicationRecord 
  resourcify

  validates :title, :title_short, :organization, presence: true

  belongs_to :organization
  has_many :routes

  has_many :carpool_locations, inverse_of: :carpool, :dependent => :destroy
  has_many :locations, :through => :carpool_locations
  accepts_nested_attributes_for :carpool_locations, allow_destroy: true
  accepts_nested_attributes_for :locations, allow_destroy: true

  has_many :active_passenger_members, -> {is_active.is_passenger}, :class_name => 'CarpoolUser', inverse_of: :carpool
  has_many :active_passengers, :class_name => 'User', :through => :active_passenger_members, :source => :user

  has_many :active_driving_members, -> {is_active.is_driver}, :class_name => 'CarpoolUser', inverse_of: :carpool
  has_many :active_drivers, -> { all_can_drive }, :class_name => 'User', :through => :active_driving_members, :source => :user

  has_many :active_members, -> {is_active}, :class_name => 'CarpoolUser', inverse_of: :carpool
  has_many :active_users, -> {distinct}, :class_name => 'User', :through => :active_members, :source => :user
  accepts_nested_attributes_for :active_members
  accepts_nested_attributes_for :active_users

  has_many :driving_members, -> {is_driver}, :class_name => 'CarpoolUser', inverse_of: :carpool
  has_many :drivers, -> {all_can_drive}, :class_name => 'User', :through => :driving_members, :source => :user#, :after_add => :make_dirty, :after_remove => :make_dirty
  accepts_nested_attributes_for :driving_members
  accepts_nested_attributes_for :drivers

  has_many :passenger_members, -> {is_passenger}, :class_name => 'CarpoolUser', inverse_of: :carpool
  has_many :passengers, :class_name => 'User', :through => :passenger_members, :source => :user#, :after_add => :make_dirty, :after_remove => :make_dirty
  accepts_nested_attributes_for :passenger_members
  accepts_nested_attributes_for :passengers

  has_many :unique_members, -> {distinct}, :class_name => 'CarpoolUser', inverse_of: :carpool, :dependent => :destroy
  has_many :users, -> {distinct}, :through => :unique_members, :class_name => 'User'
  has_many :google_calendar_subscribers, -> {all_google_calendar_subscribers}, :class_name => 'User', :through => :unique_members, :source => :user
  accepts_nested_attributes_for :unique_members, allow_destroy: true
  accepts_nested_attributes_for :google_calendar_subscribers
  accepts_nested_attributes_for :users, allow_destroy: true
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
        user.reset_current_carpool #if user.current_carpool == self
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
# ________________________________________

  scope :lobbies, -> {where title: LOBBY}

  def get_missing_persons(working_week)
      # Grab the week their looking at
      # @working_week = cookies[:last_viewing_moment] ? cookies[:last_viewing_moment] : "2015 09 12" #YYYY MM DD
      # This will be a Sunday, even if the cal is Mon-Fri

      missing_persons = {}

      return missing_persons if working_week == ""

      start_date = Date.iso8601(working_week)
      end_date = start_date + 6.days
      routes_within_range = routes.select {|r| r.starts_at.to_date.between?(start_date, end_date)}

      start_date.upto(end_date) do |date|

        missing_persons[date] = {}
        passengers_for_day = Array.new()
        routes_on_date = routes_within_range.select {|r| r.starts_at.to_date == date}

        routes_on_date.each do |rte|
          rte.passengers.pluck(:first_name).each do |item|
            passengers_for_day << item
          end
        end

        passenger_ride_cnts = passengers_for_day.each_with_object(Hash.new(0)) { |p, counts| counts[p] += 1 }

        active_passengers.each do |p|
          if (passenger_ride_cnts[p.first_name] < 2)
            missing_persons[date][p.first_name] = passenger_ride_cnts[p.first_name]
          end
        end

      end

      return missing_persons
  end

  def is_lobby?
    (title_short == LOBBY)
  end
  
end
