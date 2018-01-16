class EventRoute < ApplicationRecord 

  belongs_to :event#, class_name: "Event"#, touch: true
  belongs_to :google_event
  belongs_to :route#, touch: true

end
