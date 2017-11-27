class GcalCarpoolCreateDestroyCalendarsJob < ApplicationJob
  queue_as :default

  def perform(cp)

    gs = GoogleServiceAccount::Calendar.new
    # See if way to cleanup the share invitation text to exclude/rename the email address of the creater gservice account !!!
    if cp.publish_to_gcal
      # p "after_commit :create_destroy_carpool_google_calendar___________________________ publish_to_gcal = " + cp.publish_to_gcal.to_s

      org = cp.organization
      cal_title =  cp.title
      cal_title += "-DEV" if Rails.env.development?
      new_cal = gs.add_secondary_calendar(cal_title) # should give the calendar it's own title field in model !!!
      new_cal_id = new_cal.id
      cp.google_calendar_id = new_cal_id

      cp.google_calendar_subscribers.each do |user|
        gs.share_readonly(new_cal_id, user.email)
      end

      cp.routes.each do |route|
        # p "GcalCarpoolCreateDestroyCalendarsJob"
        gs.event_add(new_cal_id, route.to_google_event)
      end # add error handling !!!

    else
      unless cp.google_calendar_id.blank?
        cp.google_calendar_subscribers.each { |user| gs.unshare(cp.google_calendar_id, user.email)  unless user.email.blank? }
        gs.delete(cp.google_calendar_id)
        # if Google::Apis::ClientError notFound: Not Found
        # Maybe they raked: gs:delete_all_calendars, justcatch, log, and ignore !!!
        cp.google_calendar_id = nil
      end
    end

    cp.save

  end
end
