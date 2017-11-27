require_dependency("app/models/fullcalendar_engine/event_decorator.rb")

class EventRoute < ApplicationRecord 

  belongs_to :event, class_name: "FullcalendarEngine::Event"#, touch: true
  belongs_to :google_event
  belongs_to :route#, touch: true

end
