# app/admin/calendar.rb
ActiveAdmin.register_page "Calendar" do

  menu priority: 0

  def index
      authorize :calendars, :index?
  end

  content do
    render partial: "calendar"
  end

end
