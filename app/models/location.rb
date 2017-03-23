class Location < ActiveRecord::Base

  include DirtyAssociations

  validates :title, :short_name, :city, :carpools, presence: true

  has_many :carpool_locations, inverse_of: :location, :dependent => :destroy
  has_many :carpools, through: :carpool_locations#, :dependent => :destroy # added this destroy to try and fix the location not being destroyed
  accepts_nested_attributes_for :carpool_locations, allow_destroy: true
  accepts_nested_attributes_for :carpools, allow_destroy: true

  has_many :is_home_locations,  -> {is_home}, :class_name => 'LocationUser', inverse_of: :location, :dependent => :destroy
  has_many :residents, -> { order("first_name").uniq }, :class_name => 'User', :through => :is_home_locations, :source => :user

  has_many :is_work_locations,  -> {is_work}, :class_name => 'LocationUser', inverse_of: :location, :dependent => :destroy
  has_many :workers, -> { order("first_name").uniq }, :class_name => 'User', :through => :is_work_locations, :source => :user

  has_many :location_routes, inverse_of: :location, :dependent => :destroy
  has_many :routes, through: :location_routes

  accepts_nested_attributes_for :location_routes, allow_destroy: true
  accepts_nested_attributes_for :routes#, allow_destroy: true

  accepts_nested_attributes_for :residents, allow_destroy: true
  accepts_nested_attributes_for :is_home_locations, allow_destroy: true
  accepts_nested_attributes_for :workers#, allow_destroy: true
  accepts_nested_attributes_for :is_work_locations, allow_destroy: true

  before_destroy :save_route_ids, prepend: true
  before_save :save_route_ids, prepend: true
    def save_route_ids
      @route_ids_affected = self.routes.collect(&:id)
    end

  after_commit :dirtify_associated_route_events, on: [:destroy, :update]
    def dirtify_associated_route_events # so calendar get's updated
      Route.where(id: @route_ids_affected).each {|route| route.event.touch}
#         # Should flag as modified via an automated change tracking system,
#         # already partially implemented via templates !!!
    end

end
