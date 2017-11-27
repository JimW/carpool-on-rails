class GcalUserCreatePopulateOrgCalendarsJob < ApplicationJob
  queue_as :default

  # Create personal google calendars for this user for this organization
  # and add all their assigned events into it

  def perform(usr)
    
    gs = GoogleServiceAccount::Calendar.new

    usr.organizations.each do |org|
      # Create new personal google calendar for org
      cal_title = org.title_short + " Carpools (" + usr.first_name + ")"
      cal_title += "-DEV" if Rails.env.development?
      new_cal = gs.create_and_share_cal_as_read_only(usr.email, cal_title)
      # The above also creates an ACL id which we may need/want to store if we want to
      #  associate multiple users to a personal calendar (like for Parents for their kids's calendars) !!!
      # at least maybe an option to associate multiple/alternate emails
      orguser = usr.organization_users.where(organization_id: org.id).first
      orguser.personal_gcal_id = new_cal.id
      orguser.save

      gs.add_all_events_to_personal_org_calendar(usr, org) # TODO Batchify via Google API
    end

  end
end
