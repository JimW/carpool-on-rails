# app/admin/calendar.rb
ActiveAdmin.register_page "Calendar" do

  menu priority: 0

  def index
    authorize :calendars, :index?
  end

  controller do

    def index
      cp = current_user.current_carpool if !current_user.nil?
      context = {
        current_user: current_user, 
        current_carpool: cp
      }
      eventSources = CarPoolSchema.execute("{fcEventSources() {}}", context: context, variables: nil)
      # should snag the error if any
      @calendar_props = {
        eventSources: eventSources["data"]["fcEventSources"]
      }
    end
    
  end

  content do
    render partial: "calendar"
  end

end