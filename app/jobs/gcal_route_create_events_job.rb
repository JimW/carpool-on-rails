class GcalRouteCreateEventsJob < ActiveJob::Base
  queue_as :default

  def perform(rte)
    if (rte.category.to_sym != :template)

      gs = GoogleServiceAccount::Calendar.new#(cal_id)
      new_cal_event = rte.to_google_event # formats for google

      if (rte.carpool.publish_to_gcal)
        cal_id = rte.carpool.google_calendar_id
        if !cal_id.blank? && !new_cal_event.nil?
          # Add  event to master Carpool Calendar
          gs.event_add(cal_id, new_cal_event)
        else
          p "after_commit :create_google_event --> gs.event_add FAILED __________ rte.carpool.google_calendar_id,blank or new_cal_event.nil <<<<"
        end
      end

      # Add entries for all associated subscribers.
      subscriber_ids_current = rte.google_calendar_subscribers.pluck(:id)
      added_user_ids = Array(subscriber_ids_current) # Called after_commit so this is good

      # Add personalized event for each subscribers's calendar
      added_user_ids.each do |user_id|
        personal_cal_id = User.find(user_id).personal_gcal_id_for(rte.carpool.organization.id)
        gs.event_add(personal_cal_id, new_cal_event) if (!personal_cal_id.blank? && !new_cal_event.nil?)
      end if !added_user_ids.nil?

    end
  end
end
