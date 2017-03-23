require "google/apis/calendar_v3"
require 'googleauth'

namespace :gs do

  desc "List all events within admin's current carpool, includes deleted events, just for debugging."
  task all_events_for_admins_first_carpool: :environment do
    Google::Apis.logger.level = Logger::DEBUG
    adminCarpool = User.with_role(:admin).first.current_carpool
    if (!adminCarpool.google_calendar_id.blank?)
      carpool_id = adminCarpool.google_calendar_id
      # p adminCarpool.google_calendar_id
      gs = GoogleServiceAccount::Calendar.new()
      p gs.events(carpool_id, true)
    else
      p "Calendar not found."
    end
  end

  desc "Deletes all calendars created by service account, Warning: if done on production, everyone will have to reassociate their calendars on their phones.  You don't want to do this if you don't have to."
  task delete_all_calendars: :environment do
      GcalServiceAccountDestroyAllCalendarsJob.perform_now
  end

end
