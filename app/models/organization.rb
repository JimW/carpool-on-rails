class Organization < ActiveRecord::Base

  validates :title, :title_short, presence: true

  has_many :carpools

  has_many :organization_users
  has_many :users, :through => :organization_users

  has_many :organization_gcal_users, -> { has_gcal }, :class_name => 'OrganizationUser'
  has_many :google_calendar_subscribers, :class_name => 'User', :through => :organization_gcal_users, :source => :user

  accepts_nested_attributes_for :organization_users
  accepts_nested_attributes_for :users

  def lobby
    carpools.where(:title => "Lobby").first
  end
  
end
