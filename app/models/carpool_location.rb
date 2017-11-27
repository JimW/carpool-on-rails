class CarpoolLocation < ApplicationRecord

  belongs_to :location
  belongs_to :carpool

end
