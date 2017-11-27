class GcalUserUnsubscribeCarpoolCalendarJob < ApplicationJob
  queue_as :default
  # Remove single calendar subscription for Carpool master calendar
  def perform(usr, google_calendar_id)
    if google_calendar_id.present?
      gs = GoogleServiceAccount::Calendar.new
      gs.unshare(google_calendar_id, usr.email)
    end
  end
end
