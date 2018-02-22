require 'json'

class User < ApplicationRecord 

  # include DirtyAssociations

  String.include CoreExtensions::String::NameFormatting
  validates :first_name, :last_name, presence: true

  phony_normalize :mobile_phone, default_country_code: 'US'
  phony_normalize :home_phone, default_country_code: 'US'

  rolify strict: true

  belongs_to :current_carpool, :class_name => :Carpool, foreign_key: 'current_carpool_id'

  # attr_accessor :is_active_in_carpool
  # is acessed within carpool associations via extend: UserIsActiveInCarpool
  # to allow for easy access to join model attributes
  # http://stackoverflow.com/questions/25235025/rails-4-accessing-join-table-attributes

  has_many :carpool_users, :class_name => 'CarpoolUser', inverse_of: :user, :dependent => :destroy
  has_many :carpools, :class_name => 'Carpool', :through => :carpool_users, :source => :carpool
  accepts_nested_attributes_for :carpool_users, allow_destroy: true
  accepts_nested_attributes_for :carpools, allow_destroy: true

  has_many :is_home_locations,  -> {is_home}, :class_name => 'LocationUser', inverse_of: :user, :dependent => :destroy
  has_many :homes, :class_name => 'Location', :through => :is_home_locations, :source => :location
  accepts_nested_attributes_for :is_home_locations, allow_destroy: true
  accepts_nested_attributes_for :homes, allow_destroy: true

  has_many :is_work_locations,  -> {is_work}, :class_name => 'LocationUser', inverse_of: :user, :dependent => :destroy
  has_many :work_places, :class_name => 'Location', :through => :is_work_locations, :source => :location
  accepts_nested_attributes_for :is_work_locations, allow_destroy: true
  accepts_nested_attributes_for :work_places

  has_many :route_users, :class_name => 'RouteUser', inverse_of: :user, :dependent => :destroy
  has_many :routes, -> { distinct }, :through => :route_users, :source => :route
  accepts_nested_attributes_for :routes

  has_many :is_driver_routes,  -> {is_driver}, :class_name => 'RouteUser', inverse_of: :user, :dependent => :destroy
  # has_many :driver_routes, -> { is_special }, :class_name => 'Route', :through => :is_driver_routes, :source => :route
  has_many :driver_routes, :class_name => 'Route', :through => :is_driver_routes, :source => :route

  # has_many :is_routine_driver_routes,  -> {is_routine_driver}, :class_name => 'RouteUser', inverse_of: :user, :dependent => :destroy
  has_many :driver_routine_routes, -> { is_template }, :through => :is_driver_routes, :source => :route

  accepts_nested_attributes_for :is_driver_routes, allow_destroy: true
  accepts_nested_attributes_for :driver_routes, allow_destroy: true
  accepts_nested_attributes_for :driver_routine_routes, allow_destroy: true

  has_many :is_passenger_routes,  -> {is_passenger}, :class_name => 'RouteUser', inverse_of: :user, :dependent => :destroy
  # has_many :passenger_routes, -> { is_special }, :class_name => 'Route', :through => :is_passenger_routes, :source => :route
  has_many :passenger_routes, :class_name => 'Route', :through => :is_passenger_routes, :source => :route

  # has_many :is_passenger_routine_routes,  -> {is_routine_passenger}, :class_name => 'RouteUser', inverse_of: :user, :dependent => :destroy
  has_many :passenger_routine_routes, -> { is_template }, :through => :is_passenger_routes, :source => :route
  #{is_routine_passenger}

  accepts_nested_attributes_for :is_passenger_routes, allow_destroy: true
  accepts_nested_attributes_for :passenger_routes, allow_destroy: true
  accepts_nested_attributes_for :passenger_routine_routes, allow_destroy: true

  has_many :memberships_as_active, -> {is_active}, :class_name => 'CarpoolUser', inverse_of: :user#, :dependent => :destroy
  has_many :active_carpools, -> { distinct }, :class_name => 'Carpool', :through => :memberships_as_active, :source => :carpool
  accepts_nested_attributes_for :active_carpools, allow_destroy: true
  accepts_nested_attributes_for :memberships_as_active, allow_destroy: true

  has_many :memberships_as_driver,  -> {is_driver}, :class_name => 'CarpoolUser', inverse_of: :user#, :dependent => :destroy
  has_many :driver_memberships, -> { distinct }, :class_name => 'Carpool', :through => :memberships_as_driver, :source => :carpool
  accepts_nested_attributes_for :memberships_as_driver
  accepts_nested_attributes_for :driver_memberships

  has_many :memberships_as_passenger,  -> {is_passenger}, :class_name => 'CarpoolUser', inverse_of: :user#, :dependent => :destroy
  has_many :passenger_memberships, -> { distinct }, :class_name => 'Carpool', :through => :memberships_as_passenger, :source => :carpool
  accepts_nested_attributes_for :memberships_as_passenger
  accepts_nested_attributes_for :passenger_memberships

  has_many :organization_users, :dependent => :destroy
  has_many :organizations, :through => :organization_users
  accepts_nested_attributes_for :organization_users
  accepts_nested_attributes_for :organizations

  # belongs_to :current_organization, :class_name => :Organization, foreign_key: 'current_organization_id'

  scope :in_lobby, -> { joins(:carpools).merge(Carpool.lobbies) }
  scope :all_can_drive, -> {where :can_drive => true}
  scope :all_google_calendar_subscribers, -> { where :subscribe_to_gcal => true}

# __________________________

  before_save :remove_as_driver_in_all_carpools,
      :if => Proc.new {|user| user.can_drive_changed? && user.can_drive_change[NEWVAL]==false }
  def remove_as_driver_in_all_carpools
    # driver_memberships.destroy_all() # except lobby
    driver_memberships.each do |carpool|
      detail = carpool.driving_members.includes(:user).where(user_id: id).first # no better way?
      detail.is_driver = false # triggers call to remove_from_routes_as_driver via carpool_user's before_update
      detail.save
    end
  end

  def remove_from_routes_as_driver(carpool)
    rts = driver_routes.where(carpool_id: carpool.id).all
    rts.each { |r|
      r.remember_gcal_subscribers # could move to/around make_dirty or at least within before_update ??
      r.drivers.destroy(self)
      r.save # after_commit updates gcals
    }
  end

  def remove_from_routes_as_passenger(carpool)
    rts = passenger_routes.where(carpool_id: carpool.id).all
    rts.each { |r|
      r.remember_gcal_subscribers # could move to/around make_dirty or at least within before_update ??
      r.passengers.destroy(self)
      r.save # after_commit updates gcals
    }
  end

  def remove_from_all_routes(carpool)
    rts = routes.where(carpool_id: carpool.id).all
    rts.each { |r|
      r.remember_gcal_subscribers # could move to/around make_dirty or at least within before_update ??
      r.drivers.destroy(self)
      r.passengers.destroy(self)
      r.save # after_commit updates gcals
    }
  end

    # untested !!!
    # before_save :reset_current_carpool_on_org_change, :if => Proc.new {|user| user.current_organization.changed? }
    #   def reset_current_carpool_on_org_change
    #     current_carpool = carpools.where(:organization => current_organization).first
    #   end

    # Rethink Lobby Stuff !!!
  # before_save :add_to_lobby_if_no_carpools
  #   def add_to_lobby_if_no_carpools
  #     if !carpools.any? # should not ever really be engaged, maybe during bad seed.?
  #     # if current_carpool.nil? || !carpools.any?
  #       # p "current_organization = " + current_organization.title
  #       # p "carpools = " + current_organization.carpools.to_s
  #
  #       lobby = current_organization.lobby
  #       if lobby.present? # always..
  #         if can_drive
  #           driver_memberships << lobby
  #         else
  #           passenger_memberships << lobby
  #         end
  #         current_carpool = lobby
  #       end
  #     end
  #   end

  after_commit  :dirtify_associated_route_events, on: [:update],
      :if => Proc.new { |record|  [ :email,
                                    :first_name,
                                    :last_name,
                                    :home_phone,
                                    :mobile_phone
                                  ].any? {|k| record.previous_changes.key?(k)} }
    def dirtify_associated_route_events
      if self.routes.any?
        route_ids_affected = self.routes.collect(&:id) if self.routes.any?
        Route.batch_update_calendars_for(route_ids_affected) if route_ids_affected.any?
      end
    end

  after_commit  :create_destroy_personal_google_calendar, on: [:update],
      :if => Proc.new { |record| record.previous_changes.key?(:subscribe_to_gcal) }
    def create_destroy_personal_google_calendar
      if self.subscribe_to_gcal?
        #create/populate all org calendars - blocking
        GcalUserCreatePopulateOrgCalendarsJob.perform_now self # this needs to be blocking the calendars will be needed
        # share carpool calendars
        self.carpools.each do |carpool|
          GcalUserSubscribeCarpoolCalendarJob.perform_later(self, carpool.google_calendar_id) unless (!carpool.publish_to_gcal? || carpool.google_calendar_id.blank?)
        end
      else
        delete_unshare_all_google_calendars
      end
    end

  before_destroy  :delete_unshare_all_google_calendars,
        :if => Proc.new { |record| !record.subscribe_to_gcal? }
    def delete_unshare_all_google_calendars
      organization_users.each do |orguser|
        GcalDeleteCalendarJob.perform_now(orguser.personal_gcal_id) unless orguser.personal_gcal_id.blank?
        orguser.personal_gcal_id = nil
        orguser.save
      end
      carpools.each do |carpool|
        GcalUserUnsubscribeCarpoolCalendarJob.perform_now(self, carpool.google_calendar_id) unless carpool.google_calendar_id.blank?
      end
    end

  def personal_gcal_id_for(org_id)
    organization_users.where(organization_id: org_id).first.personal_gcal_id
  end

  # Called from Carpool upon a Carpool deletion, in case it was referenced as a current_carpool
  # this whole idea is dangerous once people start logging in, having people's current_carpools shift from underneath them
  def reset_current_carpool
    if carpools.exists? && (carpools.count > 1)
      self.current_carpool = carpools.where.not(:title => LOBBY).first # Add self.carpool_history !!!
    else
      default_carpool = Carpool.find_by(title_short: LOBBY)
      self.current_carpool = default_carpool
    end
    save
  end

  def full_name
   "#{first_name} #{last_name}"
  end

  def short_name
  #  "#{first_name}_#{last_name.initial}"
  "#{first_name}"
  end

  def short_name_with_mobile_phone
    if not ENV['DEMO_MODE']
    "#{short_name} #{mobile_phone.phony_formatted}" 
    else
    "#{full_name} (xxx) xxx-xxxx"
    end
  end

  def full_name_with_mobile_phone
    if not ENV['DEMO_MODE']
    "#{full_name} #{mobile_phone.phony_formatted}" 
    else
    "#{full_name} (xxx) xxx-xxxx" 
    end
  end

  def is_admin?
    self.has_role?(:admin)
  end

  def is_manager?(cp)
    self.has_role? :manager, cp
  end

  # :nocov:
  def super_admin?
    self.has_role?(:super_admin)
  end
  # :nocov:

  # __________________________ Devise ____________________________________________

  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  def self.from_omniauth(access_token)
      data = access_token.info
      user = User.where(:email => data["email"]).first
      # Uncomment the section below if you want users to be created if they don't exist
      # unless user
      #     user = User.create(name: data["name"],
      #        email: data["email"],
      #        password: Devise.friendly_token[0,20],
      #        first_name: data["first_name"],
      #        last_name: data["last_name"]
      #       #  Put them in the lobby here ???, should really disable this entirely
      #     )
      # end
      # "image" is also available, a link to a jpg !!!
      user
  end

  # def active_for_authentication?
  #   # Uncomment the below debug statement to view the properties of the returned self model values.
  #   # logger.debug self.to_yaml
  #
  #   super && account_active?
  # end

end
