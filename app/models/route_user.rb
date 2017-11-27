class RouteUser < ApplicationRecord

  belongs_to :route
  belongs_to :user

  scope :is_driver, -> {where(:is_driver => true)}
  scope :is_passenger, -> {where(:is_passenger => true)}

end
