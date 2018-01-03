# app/admin/calendar.rb
ActiveAdmin.register_page "Calendar" do

  menu priority: 0

  def index
    authorize :calendars, :index?
  end

  controller do

    def index
      eventSources = CarPoolSchema.execute("{fcEventSources() {}}", variables: nil)
      @calendar_props = {
         eventSources: eventSources["data"]["fcEventSources"]
      }
    end
  end

  content do
    render partial: "calendar"
  end

end