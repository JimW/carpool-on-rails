class GoogleEvent < ApplicationRecord 

  has_one :google_event_route, foreign_key: "google_event_id", :dependent => :destroy
  has_one :route, through: :google_event_route, :dependent => :destroy

end
