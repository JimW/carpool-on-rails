class OrganizationUser < ApplicationRecord

  belongs_to :organization
  belongs_to :user

  # scope :has_gcal, -> {where.not(personal_gcal_id: '')}
  # User has a google flag, but this is more real world

end
