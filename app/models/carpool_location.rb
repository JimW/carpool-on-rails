class CarpoolLocation < ActiveRecord::Base

  belongs_to :location
  belongs_to :carpool

end
