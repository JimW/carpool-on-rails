# app/admin/calendar.rb
ActiveAdmin.register_page "Calendar" do

  menu false#priority: 0

  def index
      authorize :calendars, :index?
  end

  content do
    render partial: "calendar"
  end

end
