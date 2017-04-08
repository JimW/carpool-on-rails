class GcalDeleteCalendarJob < ActiveJob::Base
  queue_as :default

  def perform(google_calendar_id)
    
    gs = GoogleServiceAccount::Calendar.new

    if google_calendar_id.present?
        gs.delete(google_calendar_id)
    end
  end
end
