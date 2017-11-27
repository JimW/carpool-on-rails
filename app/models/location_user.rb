class LocationUser < ApplicationRecord 

  belongs_to :location
  belongs_to :user

  scope :is_work, -> {where(:is_work => true)}
  scope :is_home, -> {where(:is_home => true)}

end
