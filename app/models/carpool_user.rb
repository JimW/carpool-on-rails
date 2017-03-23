class CarpoolUser < ActiveRecord::Base

  belongs_to :user
  belongs_to :carpool

  scope :is_driver, -> {where(:is_driver => true)}
  scope :is_passenger, -> {where(:is_passenger => true)}

end
