class GcalUserSubscribeCarpoolCalendarJob < ActiveJob::Base
  queue_as :default

  # Remove single calendar subscription for Carpool master calendar
  
  def perform(usr, google_calendar_id)
    if !google_calendar_id.blank? 
      gs = GoogleServiceAccount::Calendar.new
      gs.share(google_calendar_id, usr.email, "reader")  
    end
  end
end
