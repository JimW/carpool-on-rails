class CarpoolRoute < ActiveRecord::Base

  belongs_to :route
  belongs_to :carpool

end
