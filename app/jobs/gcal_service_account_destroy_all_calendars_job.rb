class GcalServiceAccountDestroyAllCalendarsJob < ApplicationJob
  queue_as :default

# NOTE: This is meant to be done when you reset the database, as a way to ensure that all google calendars associated with the service
# account are deleted.  This inlcudes all the member calendars.  Be careful ..

  def perform()

    gs = GoogleServiceAccount::Calendar.new
    gs.remove_all_secondary # Can take like 15 seoncds if you have a lot of them

  end

end
