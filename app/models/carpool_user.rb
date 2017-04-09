class CarpoolUser < ActiveRecord::Base
    
  belongs_to :user
  belongs_to :carpool
  
  scope :is_active, -> {where(:is_active => true)}
  scope :is_driver, -> {where(:is_driver => true)}
  scope :is_passenger, -> {where(:is_passenger => true)}

  before_update :deal_with_driver_disabled, prepend: true, :if => Proc.new {|cu| cu.is_driver_changed? && cu.is_driver_change[NEWVAL]==false }
    def deal_with_driver_disabled
      user.remove_from_routes_as_driver(carpool)
    end

  before_update :deal_with_passenger_disabled, prepend: true, :if => Proc.new {|cu| cu.is_passenger_changed? && cu.is_passenger_change[NEWVAL]==false }
    def deal_with_passenger_disabled
      user.remove_from_routes_as_passenger(carpool)
    end

  before_update :deal_with_active_disabled, prepend: true, :if => Proc.new {|cu| cu.is_active_changed? && cu.is_active_change[NEWVAL]==false }
    def deal_with_active_disabled
      user.remove_from_all_routes(carpool)
    end

  after_create :subscribe_user_to_calendar, prepend: true, :if => Proc.new {|cu| cu.user.subscribe_to_gcal }
    def subscribe_user_to_calendar
      # user.create_destroy_personal_google_calendar # based on can_drive, should split this method up !!!
      GcalUserSubscribeCarpoolCalendarJob.perform_later(user, carpool.google_calendar_id) if carpool.publish_to_gcal?
    end

  before_destroy :unassign_user
    def unassign_user
      user.remove_from_all_routes(carpool)
      GcalUserUnsubscribeCarpoolCalendarJob.perform_later(user, carpool.google_calendar_id)
    end

end
