require "google/apis/calendar_v3"

class GcalCancelEventJob < ApplicationJob
  queue_as :default

  def perform(gcal_id, event_data)
      gs = GoogleServiceAccount::Calendar.new#(rte.carpool.google_calendar_id)
      evt = gs.create_google_event_object (event_data)
      gs.event_delete(gcal_id, evt)
  end

end
