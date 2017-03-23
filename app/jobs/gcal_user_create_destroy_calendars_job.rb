class GcalUserCreateDestroyCalendarsJob < ActiveJob::Base
  queue_as :default

  def perform(usr)
    gs = GoogleServiceAccount::Calendar.new
    if usr.subscribe_to_gcal
      usr.organizations.each do |org|
        # Create new personal google calendar for this user for this organization
        # This calendar will hold all assignments for this usr, across all carpools
        cal_title = org.title_short + " Carpool (" + usr.first_name + ")"
        cal_title += "-DEV" if Rails.env.development?
        new_cal = gs.create_and_share_cal_as_read_only(usr.email, cal_title)
        # The above also creates an ACL id which we may need/want to store if we want to
        #  associate multiple users to a personal calendar (like for Parents for their kids's calendars) !!!
        orguser = usr.organization_users.where(organization_id: org.id).first
        orguser.personal_gcal_id = new_cal.id
        orguser.save
        gs.add_all_personal_events_to_gcal(usr, org)
      end
      # Each carpool has a calendar that holds all the routes beyond just this user's.
      # Share it with them in case they want it
      usr.carpools.each do |carpool|
        gs.share(carpool.google_calendar_id, usr.email, "reader")  unless (!carpool.publish_to_gcal || carpool.google_calendar_id.blank?)
      end

    else # delete the calendar

      usr.organization_users.each do |orguser|
        gs.delete(orguser.personal_gcal_id)
        orguser.personal_gcal_id = nil
        orguser.save
      end
      usr.carpools.each do |carpool|
        # Untested below...
        gs.unshare(carpool.google_calendar_id, usr.email) unless carpool.google_calendar_id.blank?
      end
    end
  end
end
