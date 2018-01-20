class EventRoute < ApplicationRecord 

  belongs_to :event
  belongs_to :google_event
  belongs_to :route

end
