class LocationRoute < ActiveRecord::Base

  belongs_to :location
  belongs_to :route, :touch => true # ensure not sparking 2 notifications for a create ??? !!!
  acts_as_list :scope => :route
  # column: :position,

end
