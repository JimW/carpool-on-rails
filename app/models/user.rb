class User < ActiveRecord::Base

  # include DirtyAssociations

  String.include CoreExtensions::String::NameFormatting
  validates :first_name, :last_name, presence: true

  rolify :before_add => :before_add_method#, strict: true
  def before_add_method(role)
    # do something before it gets added
  end
  # acts_as_token_authenticatable

  # __________________________ Relations: Locations

  # The below can be found for now through carpool.organization
  # belongs_to :organization, foreign_key: 'default_organization_id' # someday I'll use this as more of a setting, but for now, it's the one and only
  belongs_to :current_carpool, :class_name => :Carpool, foreign_key: 'current_carpool_id'
  # belongs_to :lobby, :class_name => :Carpool, foreign_key: 'carpool_lobby_id'

  has_many :carpool_users, :class_name => 'CarpoolUser', inverse_of: :user, :dependent => :destroy
  has_many :carpools, :class_name => 'Carpool', :through => :carpool_users, :source => :carpool
  accepts_nested_attributes_for :carpool_users
  accepts_nested_attributes_for :carpools

  has_many :is_home_locations,  -> {is_home}, :class_name => 'LocationUser', inverse_of: :user, :dependent => :destroy
  has_many :homes, :class_name => 'Location', :through => :is_home_locations, :source => :location
  accepts_nested_attributes_for :is_home_locations, allow_destroy: true
  accepts_nested_attributes_for :homes, allow_destroy: true

  has_many :is_work_locations,  -> {is_work}, :class_name => 'LocationUser', inverse_of: :user, :dependent => :destroy
  has_many :work_places, :class_name => 'Location', :through => :is_work_locations, :source => :location
  accepts_nested_attributes_for :is_work_locations, allow_destroy: true
  accepts_nested_attributes_for :work_places

  has_many :route_users, :class_name => 'RouteUser', inverse_of: :user, :dependent => :destroy
  has_many :routes, -> { uniq }, :through => :route_users, :source => :route
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

  has_many :memberships_as_driver,  -> {is_driver}, :class_name => 'CarpoolUser', inverse_of: :user, :dependent => :destroy
  has_many :driver_memberships, -> { uniq }, :class_name => 'Carpool', :through => :memberships_as_driver, :source => :carpool
  accepts_nested_attributes_for :memberships_as_driver, allow_destroy: true
  accepts_nested_attributes_for :driver_memberships, allow_destroy: true

  has_many :memberships_as_passenger,  -> {is_passenger}, :class_name => 'CarpoolUser', inverse_of: :user, :dependent => :destroy
  has_many :passenger_memberships, -> { uniq }, :class_name => 'Carpool', :through => :memberships_as_passenger, :source => :carpool
  accepts_nested_attributes_for :memberships_as_passenger, allow_destroy: true
  accepts_nested_attributes_for :passenger_memberships, allow_destroy: true

  has_many :organization_users, :dependent => :destroy
  has_many :organizations, :through => :organization_users
  accepts_nested_attributes_for :organization_users
  accepts_nested_attributes_for :organizations

  belongs_to :current_organization, :class_name => :Organization, foreign_key: 'current_organization_id'

  scope :all_can_drive, -> {where :can_drive => true}
  scope :all_can_not_drive, -> { where :can_drive => false}
  scope :all_google_calendar_subscribers, -> { where :subscribe_to_gcal => true}

  # TODO: Verify need for all these allow_destroys
# __________________________

  # if can_drive is changing to false, remove any driving assiciations
  before_save :reset_carpool_associations, :if => Proc.new {|user| user.can_drive_changed? }
    def reset_carpool_associations
      # p "reset_carpool_associations  _________________________________"
      existing_carpool_ids = []
      existing_carpool_ids = carpools.collect(&:id)
      carpool_users.destroy_all if carpool_users.any?
      save_route_ids # to use them to dirtify routes after_commit which is looking at can_drive_changed
      route_users.destroy_all if route_users.any?

      # recreate new membership associations with proper type
      if can_drive # could a member be a driver in one and a passenger in another.. ???
        # Better way to do this ???
        existing_carpool_ids.each { |id|
          driver_memberships << Carpool.find(id)
        }
      else
        existing_carpool_ids.each { |id|
          passenger_memberships << Carpool.find(id)
        }
      end
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

  # ____________ For Proper Calendar Event Sync__________
  before_destroy :save_route_ids, prepend: true # need the prepend when
    def save_route_ids
      @route_ids_affected = self.routes.collect(&:id)
    end

  after_commit :dirtify_associated_route_events, on: [:destroy, :update]
    def dirtify_associated_route_events # so calendar get's updated
      # login causes unimportant updates, so we filter update events here
      # Only if a change will affect a google calendar, we force that entry to update
      #  WHat about the routes that got disassociated during the change
      # should just ignore the last_sign_in_at, current_sign_in_ip, sign_in_count, etc
      if (transaction_include_any_action?([:destroy]) ||
         (transaction_include_any_action?([:update]) &&
            ( !previous_changes['email'].nil? ||
              !previous_changes['first_name'].nil? ||
              !previous_changes['last_name'].nil? ||
              !previous_changes['home_phone'].nil? ||
              !previous_changes['mobile_phone'].nil? ||
              !previous_changes['can_drive'].nil?
             )
          )
       )
      #  Upon update of a route's times, how can I ensure that the _record_changes contains a value !!!
        if previous_changes['can_drive']
          # p "can_drive_changed_-------> and we already saved the old routes: " + @route_ids_affected.to_s
        else
          @route_ids_affected = self.routes.collect(&:id) if self.routes.any? # otherwise it's done before_destroy
        end
        p "dirtify_associated_route_events -------> route.make_dirty for: " + @route_ids_affected.to_s
        @route_ids_affected.each do |route_id|
          route = Route.find(route_id)
          route.make_dirty(route.google_calendar_subscribers.pluck(:id))
          # Should flag as modified via an automated change tracking system, already partially implemented via templates !!!
          route.save
        end unless @route_ids_affected.nil?
      end
    end
    # __________________________________________________________________________

  # def manages
  #     Carpool.with_role(:manager, self)
  # end

  after_commit :create_destroy_personal_google_calendar, on: [:update], :if => Proc.new { |record| record.previous_changes.key?(:subscribe_to_gcal) }
                                                                        # Only if the subscribe_to_gcal changed
    def create_destroy_personal_google_calendar
      GcalUserCreateDestroyCalendarsJob. perform_later self
    end

  def personal_gcal_id_for(org_id)
    self.organization_users.where(organization_id: org_id).first.personal_gcal_id
  end

  # Called from Carpool upon a Carpool deletion, in case it was referenced as a current_carpool
  def reset_current_carpool
    if carpools.any? && (carpools.count > 1)
      p "self.current_carpool = carpools.first"
      self.current_carpool = carpools.first # or maybe smarter to attach to last updated or something !!!
    else
      default_carpool = Carpool.find(title_short: "Lobby").first
      self.current_carpool = default_carpool
      p "self.current_carpool = default_carpool"
    end
    save
    # lobby = Carpool.where(:title => "Lobby").first # change to org.lobby !!!
  end

  def full_name
   "#{first_name} #{last_name}"
  end

  def short_name
  #  "#{first_name}_#{last_name.initial}"
  "#{first_name}"
  end

  def short_name_with_mobile_phone
     "#{short_name} #{mobile_phone}"
  end

  def full_name_with_mobile_phone
     "#{full_name} #{mobile_phone}"
  end

  def is_admin?
    self.has_role?(:admin)
  end

  def is_manager?(cp)
    self.has_role? :manager, cp
  end

  def super_admin?
    self.has_role?(:super_admin)
  end

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

  # ____________________________________________________________________________

end
