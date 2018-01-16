require "google/apis/calendar_v3"
require 'googleauth'

class GoogleServiceAccount::Calendar

  Google::Apis.logger.level = Logger::WARN
    # You can set the logging level to one of the following:
    # FATAL (least amount of logging)
    # ERROR
    # WARN
    # INFO
    # DEBUG (most amount of logging)

# Create calendar within organizer's google account (organizer will need this permission request (special interaction for additional API MAYBE))
# Share calendar with the service account's email (how many can an account have??? MAYBE)
# Add service accont to carpool organizer's account via ACL, giving role of ...?
# Maybe have webapp keep a reference to the acl id?

  # Just used for deleting google events right now, update and create are using the to_google_event.  They should probably all use this now !!!
  # I needed this method during delete, because the event might be deleted by the time the job runs so I had to make it more autonomousey. look it up..
  def create_google_event_object(event_data)
    google_event_to_return = nil

    # Convert times to appease the great google
    event_data[:start] = Google::Apis::CalendarV3::EventDateTime.new(date_time: event_data[:start])
    event_data[:end] = Google::Apis::CalendarV3::EventDateTime.new(date_time: event_data[:end])

    event_defaults = {
      guests_can_modify: false,
      guests_can_see_other_guests: false,
      guests_can_invite_others: false,
      locked: true # change? !!!
    }
    # colorRgbFormat: true,
    google_event_to_return = Google::Apis::CalendarV3::Event.new(event_defaults.merge(event_data))

    return google_event_to_return
  end

  # This needs cleaning up !!!

  # def initialize(refresh_token:, time_zone:)
  def initialize(calendar_id = "primary")
    set_calendar(calendar_id)
    # @calendar
    # @refresh_token = refresh_token
    # @time_zone = time_zone

      # client = Google::APIClient.new(
      #     :application_name => 'Carpool 2 Server',
      #     :application_version => '1.0.0'
      #  )
  end

  def set_calendar(calendar_id = "primary")
    @calendar_id = calendar_id
  end

  def events(cal_id, show_deleted = nil)
    cservice.
      list_events(
        cal_id,
        show_deleted: show_deleted
        # max_results: 10,
        # single_events: true,
        # order_by: "startTime",
        # time_min: Time.now.in_time_zone(time_zone).beginning_of_day.iso8601,
        # time_max: Time.now.in_time_zone(time_zone).end_of_day.iso8601
    ).items
  end

  # Maint Util
  def remove_trash_calendars
    # show_hidden: true, show_deleted: true, max_results: 249
    cservice.list_calendar_lists.items.each do |list_entry|
      if list_entry.summary.include? "TRASH"
        cservice.delete_calendar(list_entry.id) { |result, err|
        }
      end
    end
  end

  def remove_all_secondary(cservice = self.cservice)
    calendars_to_delete = cservice.list_calendar_lists.items
    cservice.batch do |cservice|
      calendars_to_delete.each do |list_entry|
        cservice.delete_calendar(list_entry.id) { |result, err| } if !list_entry.primary
      end
    end if calendars_to_delete.any?
  end

  def remove_calendars(cal_name, cservice = self.cservice) # Not used
    cservice.list_calendar_lists.items.each do |list_entry|
      if list_entry.summary == cal_name
        cservice.delete_calendar(list_entry.id) { |result, err|
        }
      end
    end
  end

  # For when I reset the database and duplicate event_ids will start comming in
  # Manually called from command line, should wrap into bash something !!!
  def reset(cal_id) # do this by real cal_id !!!
    # cservice.clear_calendar(cal_id) # Won't work for anything... Must be bug

    # First delete all events (mark as cancelled, so as not to trigger organizer change error when moving)

    cal_name = cservice.get_calendar(cal_id).summary
    trash_cal_name = cal_name + "_TRASH"
    trash_cal = add_secondary_calendar(trash_cal_name)

    # share(trash_cal.id, "api@xx.com", "owner") # maybe necessary to have all owners be ok with move?

    events(cal_id, true).each do |event|  # move item to trash, true shows deleted events
      # calendar.delete_event(event.id) # delete won't truely delete because it's google..
      # so send it to another calendar
      cservice.move_event(cal_id, event.id, trash_cal.id)
    end
    # and then delete the trash calendar
    # remove_calendars(trash_cal_name)
    # cannotChangeOrganizer error catch
  end

  def find_or_create_calendar(cal_name, cservice = self.cservice)
    cal = nil
    cservice.list_calendar_lists.items.each do |list_entry|
      if list_entry.summary == cal_name
        cal = cservice.get_calendar(list_entry.id) { |result, err|
        }
      end
    end
    if cal.nil?
      cal = add_secondary_calendar(cal_name)
    end

    cal
  end

  def add_all_events_to_personal_org_calendar(user, org, cservice = self.cservice)
    #TODO https://developers.google.com/api-client-library/ruby/guide/batch
    if user.present? && org.present?
      cid = user.personal_gcal_id_for(org.id) 
      if cid.present?
        # insert events into personal calendar for each assigned route in every carpool
        org.carpools.collect(&:id).each do |carpool_id|
          user_carpool_routes = user.routes.where(carpool_id: carpool_id)
          cservice.batch do |cservice|
            user_carpool_routes.each do |route|
              # p "_______________ add_all_events_to_personal_org_calendar: adding route"
              event_add(cid, route.to_google_event, cservice)
            end
          end if user_carpool_routes.any?
        end
      else
        p "add_all_events_to_personal_org_calendar: ++++++++++++++++++++++++++ no personal_gcal_id"
      end
    end
  end

  def create_and_share_cal_as_read_only(share_email, cal_title)
    new_cal = add_secondary_calendar(cal_title)
    share(new_cal.id, share_email, "reader")
    new_cal
  end

  def delete(cal_id, cservice = self.cservice)
    cservice.delete_calendar(cal_id) do |result, err|
    end
  end

  # def update(cal_id, google_calendar)
  #   cservice.update_calendar(cal_id, google_calendar) do |result, err|
  #   end
  # end

  def unshare(cal_id, share_email, cservice = self.cservice)
    acls = cservice.list_acls(cal_id)
    acl_rule = acls.items.select { |acl| acl.scope.value.eql? share_email}
    cservice.delete_acl(cal_id, acl_rule[0].id) { |result, err|
      # TODO
    } unless acl_rule[0].nil?
  end

  def share_readonly(cal_id, share_email)
    share(cal_id, share_email, "reader")
  end

  def share(cal_id, share_email, role, cservice = self.cservice)
    # p "About top share: " + share_email + " with cal_id: " + cal_id
    acl_scope = Google::Apis::CalendarV3::AclRule::Scope.new
    acl_scope.type = :user
    acl_scope.value = share_email
    acl_rule = Google::Apis::CalendarV3::AclRule.new
    acl_rule.role = role
    acl_rule.scope = acl_scope
    cservice.insert_acl(cal_id, acl_rule) { |result, err|
      # TODO
    }
  end

  def add_secondary_calendar(cal_name, cservice = self.cservice)
    new_cal = Google::Apis::CalendarV3::Calendar.new(summary: cal_name)
    new_cal = cservice.insert_calendar(new_cal) do |result, err|
    end
    new_cal
  end

  def event_undelete(cal_id, google_event, cservice = self.cservice)
    # check valids params !!!
    # p "calendar: event_undelete for HEY summary = " + google_event.summary
    # Clean this up !!!
    google_event.status = "confirmed"
    cservice.patch_event(cal_id, google_event.id, google_event) { |res, err|
      # case err.to_s
      # # when 'duplicate'
      # #   p "delete found duplicate _____________  assuming it's really marked as cancelled"
      # # when 'forbidden'
      # #   p "forbidden _________"
      # end
      # Error - #<Google::Apis::ClientError: notFound> !!!, in case the calendar is deleted within google by a shared owner
      p "calendar.event_undelete ERROR = " + err.to_s if !err.nil?
      # p "calendar.event_undelete RESPONSE = " + res.to_s if !res.nil?
    }
  end

  def event_delete(cal_id, google_event, cservice = self.cservice)
    # Passing google_event in case the delete fails due to the status marked as cancelled
    event_id_hex = !google_event.nil? ? google_event.id : nil
    # p "+++++++++++++++++++++++++++++++++++++++++++++++++ calendar: event_delete for " + google_event.summary
    # p "+++++++++++++++++ calendar: event_delete for " + event_id_hex.to_s

    # If this fails, because it's called from a BEFORE_save in Routes, it stops the Route deletion, but the associated Event deletion already ocurred
    # !!!, how to best wrap all this stuff into a transaction ??? Rethink when I add workers/jobs

    if event_id_hex
      cservice.delete_event(cal_id, event_id_hex) { |res, err|
        case err.to_s
        # when 'duplicate'
        #   p "delete found duplicate ______, assuming it's really marked as cancelled"
        #   event_undelete(cal_id, google_event)
        when 'forbidden'
          p "forbidden _____________ "
        when 'notFound' #in case the calendar is deleted within google by a shared owner
          p "notFound ______________ "
        when 'Invalid Request'
          p 'INVALID REQUEST ____________ for ' + event_id_hex
        when 'deleted: Resource has been deleted'
          p 'deleted: Resource has been deleted __________ CAUGHT for ' + event_id_hex
        end
        p "calendar.event_delete ERROR = " + err.to_s if !err.nil?
        # p "calendar.event_delete RESPONSE = " + res.to_s if !res.nil?
      }
    end
  end

  def event_add(cal_id, google_event, cservice = self.cservice) # pass cservice so it can be passed in by batching callers
    # puts "____ event_add CALLER = " + caller[0]
    if !google_event.nil? && !cal_id.nil?
      #  p "About to insert_event $$$: " + google_event.summary + " with " + google_event.id.to_s + " into " + cal_id
      cservice.insert_event(cal_id, google_event) { |res, err|
        case err.to_s
        when 'duplicate: The requested identifier already exists.' 
          # watch out, they change this text ... must find some static codes I can use from somewhere, just use delete_all_calendars task and you're safe
          p "insert_event found duplicate ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++, assuming it's really marked as cancelled"
          event_undelete(cal_id, google_event)
        when 'forbidden'
          p "forbidden ________________"
        else
          p "calendar.insert_event ERROR = " + err.to_s if !err.nil?
        end
        # Error - #<Google::Apis::ClientError: notFound> !!!, in case the calendar is deleted within google by a shared owner
        #  p "calendar.insert_event RESPONSE = " + res.to_s if !res.nil?
      }
    else
      p "event_add:  google_event or cal_id is NULL +++++++++++++++++++++++++++++++++++++++++"
    end
  end

  def event_update(cal_id, google_event, cservice = self.cservice)
    if google_event
      cservice.update_event(cal_id, google_event.id, google_event) { |res, err|
        # case err
        # when 'duplicate' # it must use the id field
        #   p "Found DUPLICATE ________________"
        # end

        # When  I had no internet, testing locally:
        # [ActiveJob] [GcalRouteUpdateEventsJob] [7390f275-9592-46fe-b83a-92acb8d7c58e] Caught error notFound: Not Found
        # 17:12:24 web.1    | [ActiveJob] [GcalRouteUpdateEventsJob] [7390f275-9592-46fe-b83a-92acb8d7c58e] Error - #<Google::Apis::ClientError: notFound: Not Found>
        # 17:12:24 web.1    |
        # 17:12:24 web.1    | "++++++++++++++++++++++++++++++++++++++++++++++++++ calendar.event_update ERROR = notFound: Not Found"

        if err
          # possible errors 'duplicate'
          p "++++++++++++++++++++++++++++++++++++++++++++++++++ calendar.event_update ERROR = " + err.to_s
        #else
          #p "calendar.event_update RESPONSE = " + res.to_s
        end
      }
    else
      p "event_update fAILED because of NULL google_event +++++++++++++++++++++++++++++++++++++++++"
    end
  end

  # _____
  def cservice
    @cal_service ||= setup_calendar
  end
  private
  attr_reader :refresh_token, :time_zone # take out ???

  def setup_calendar
    Google::Apis::RequestOptions.default.retries = 5
    cal_service = Google::Apis::CalendarV3::CalendarService.new
    cal_service.authorization = setup_authorization
    # calendar.authorization.fetch_access_token!
    cal_service
  end

  def setup_authorization
    authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      scope: 'https://www.googleapis.com/auth/calendar',
      json_key_io: StringIO.new(ENV['MY_SERVICE_ACCOUNT_JSON'])
    )
    authorization
  end

end
