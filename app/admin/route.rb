require_dependency("../app/models/fullcalendar_engine/event_decorator.rb")

ActiveAdmin.register Route do
  menu priority: 1
  config.clear_action_items! # removes "Create New Route" button
# https://github.com/activeadmin/activeadmin/issues/3676
# Maybe the issue with the ransack error is because the join table is missing an id field?
# That's why I had to remove these filters, or at least define them explicetely
  # filter :carpool, collection: proc { current_user.carpools }
  # filter :carpool, if: proc { current_user.has_role?(:admin) }
  # filter :title_cont, label: 'Route Title'#,:as => :multiple_select

  config.filters = false
  # filter :drivers, as: :check_boxes,  collection: proc { current_user.current_carpool.drivers.order('name').all }
  # filter :passengers, as: :check_boxes, collection: proc { current_user.current_carpool.passengers.order('name').all }
  # filter :locations, as: :check_boxes, collection: proc { current_user.current_carpool.locations.order('title').all }

  # filter :is_template, as: :select, collection: [["Yes", true], ["No", false]]
  # filter :category, label: 'Type', as: :check_boxes, collection: Route.categories
  # http://stackoverflow.com/questions/16967611/active-admin-toggle-scope-with-filter
  # filter :bar, :as => :select, :collection => {:true => nil, :false => false }

  # sidebar :carpool_managers do
  #   mail_to current_user.current_carpool.manager_names_and_emails
  # end
  # https://github.com/activeadmin-plugins/active_admin_sidebar

# TODO Remove non-essential stuff
permit_params do
  permitted = [
    :request_type, :filtered_route_ids, :order, :dup_as, :event_id, :starttime, :endtime, :working_week,
    :category, :title, :description, :starts_at, :ends_at,
    :starts_at_date, :starts_at_time_hour, :starts_at_time_minute, :ends_at_date, :ends_at_time_hour, :ends_at_time_minute,
    location_ids:[],
    passenger_ids:[],
    driver_ids:[],
    routine_driver_ids:[],
    routine_passenger_ids:[]
    ]
  permitted
end

batch_action :destroy do |ids|
  ids.each do |id|
    @route = Route.find(id)
    @route.destroy
  end
  redirect_to collection_path, alert: "Selected Routes Deleted."
end

# Need to clean some of this out !!! Talking to normal controllers in some places

# this sets up the route so keep it in, I think..
collection_action :duplicate, method: [:post] do
  if request.post?
    # p "params[:event_id] = " + params[:event_id]
    # head :ok
  else
    # render :foo
  end
end

# this sets up the route so keep it in, I think..
collection_action :jump_to_calendar_event, method: [:get] do
end


# this sets up the route so keep it in, I think..
collection_action :refresh_calendar, method: [:get] do
  # if request.get?
  #  p "params[:working_date] = " + params[:working_date]

  #  p "params[:event_id] = " + params[:event_id]
  #  @event_id = params[:event_id]
  #   # head :ok
  # else
  #   # render :foo
  # end
end

# this sets up the route so keep it in, I think..
collection_action :update_via_event, method: [:post] do
  if request.post?
    # p "params[:event_id] = " + params[:event_id]
    # head :ok
  else
    # render :foo
  end
end

# Should expand this out to ajaxafy more
collection_action :get_events, method: [:get] do
  if request.post?
    # p "params[:event_id] = " + params[:event_id]
    # head :ok
  else
    # render :foo
  end
end

# ___________________ index ____________________________________________________

config.sort_order = 'starts_at_desc'

index do
  session[:search] = params[:q] ? params[:q] : nil
  session[:working_date] = params[:working_date] ? params[:working_date] : "2017-02-26" # !!!
  @working_date = session[:working_date]
  @most_recent_date_edit = Route.order("updated_at").last

  render partial: 'route_calendar'
  # render partial: 'missing_routes'

  # id_column
  selectable_column
  column "Time", sortable: :starts_at  do |route|
    # Ajax example:
    link_to route.starts_at.strftime("%a %d - %l:%M %p"), jump_to_calendar_event_admin_routes_path(:route_id => route.id), :remote => true
  end
  column :title#_for_admin_ui
  # column :category
  column :actions do |resource|
    links = link_to I18n.t('active_admin.view'), resource_path(resource)
    links += link_to "  " + I18n.t('active_admin.delete'), resource_path(resource), :method => :delete if current_user.has_any_role? :admin, { :name => :manager, :resource => current_user.current_carpool }
    links
  end
end
# ___________________ show _____________________________________________________

show do

  attributes_table do
    row :title
    row :category
  end

  panel "Assignments" do
    if route.drivers.any?
        table_for route.drivers do
          column "Drivers" do |user|
            li user.full_name
          end
        end  # end
    end
    if route.passengers.any?
      table_for route.passengers do
        column "Passengers" do |user|
          li user.full_name
        end
      end  # end
    end
  end
  panel "Locations" do
    table_for route.locations do
      column "name" do |location|
        location.title
      end
    end
  end
end
# ___________________ form _____________________________________________________

form do |f|

end

# ______________________________ controller ____________________________________

controller do

  before_filter {
    @page_title = "Routes for #{current_user.current_carpool.title_short}"
  }

  def update(options={}, &block)

    @route = Route.find(permitted_params[:id])
    @route._record_changes = @route.google_calendar_subscribers.pluck(:id)
    # obsolete by next line and can take out ??? !!!

    @route.remember_gcal_subscribers

    cookies.permanent[:last_working_date] = @route.starts_at.iso8601

    super do |success,failure|
      success.html {
        session[:last_route_id_edited] = @route.id
        redirect_to collection_path
      }
      failure.html { render :edit }
    end
  end # update

  def destroy(options={}, &block) # ____________________________________________

    if request.xhr?
      # It's really an event ID from the FullcalendarEngine stuff
      @route = FullcalendarEngine::Event.find(permitted_params[:id]).route
    else
      @route = Route.find(permitted_params[:id])
    end
    # p "Admin:Route:destroy found " + @route.title_for_admin_ui

    if @route.template? && @route.scheduled_instances #.for_today?
      @route.scheduled_instances.each do |route_inst|
        # p "SPECIALZ for " + route_inst.title
        route_inst.category = :special # convert instances to :special, don't just delete them all
        # route_inst.update_columns(category: :special)
        # rte.special! # also this action should not trigger any notifications to users (for the future.. !!!)
        route_inst.save
        session[:last_route_id_edited] = route_inst.id # used to plant a Class to mark the event in the calendar, so the js can highlight the change and scroll to it.
        # what about relationship..
      end
    # else
      # session[:last_route_id_edited] = "" # Last thing edited is gone now.
    end

    # Should change response for JS??? I'm just calling from the JS into Route_Controller instead of AA
    super do |success, failure|
      block.call(success, failure) if block
      failure.html { render :edit }
    end
  end

  def edit # ___________________________________________________________________
    if request.xhr?
      # It's really an event ID, so look it up
      @route = FullcalendarEngine::Event.find(permitted_params[:id]).route
      # p "Admin: Route: Controller: edit (request.xhr), route_id = " + @route.id.to_s
    else
      @route = Route.find(permitted_params[:id])
    end
    @id = @route.id
  end

  def new # ____________________________________________________________________
     new! do |format|
        #  format.html #{ render active_admin_template('new') }
         format.js
       end
  end

  def create(options={}, &block) # _____________________________________________

    @route = Route.new(permitted_params[:route])
    @route.category = :special
    @route.carpool = current_user.current_carpool
    @route.event =  FullcalendarEngine::Event.new({
        :starttime => @route.starts_at,
        :endtime => @route.ends_at #starts_at + 30.minutes # Conifiga !!! default_route_time, later it will auto-calc based on locations
    })
    cookies.permanent[:last_working_date] = @route.starts_at.iso8601

    # session[:route_action] = "create"

    super do |success,failure|
      success.html {
        # @route.event.save # To force it to reset it's title, Can't do in after_save .? issues with event after_save setting Route.title # no longer needed ? !!! double check/test
        session[:last_route_id_edited] = @route.id # used to plant a Class to mark the event in the calendar, so the js can highlight the change and scroll to it.
        redirect_to collection_path
      }
      failure.html { render :edit }
    end

  end # create


  def update_via_event # _______________________________________________________
    if request.xhr?

      update_type = params[:update_type]

      event_clicked = FullcalendarEngine::Event.find(params[:event_id])

      # if event_clicked.route.modified_instance? && event_clicked.route.instance_parent.any?
      # end

      if (update_type == 'instance_revert')
        new_route = event_clicked.route.instance_parent.deep_clone :include => [:drivers, :passengers, :locations]

        # Setting of instance_parent not quite right, seems OK in db.. #1 check there, then maybe nowhere I've actually used this association!!!
        new_route.instance_parent = event_clicked.route.instance_parent

        # !!! This will need to dynamically determine the actual date for the instance template (using day of week of template and date of exhisting instance)
        new_route.event =  FullcalendarEngine::Event.new({
            :starttime => event_clicked.route.instance_parent.event.starttime.iso8601,
            :endtime => event_clicked.route.instance_parent.event.endtime.iso8601
        })

        event_clicked.route.destroy # not deleteing the event for some reason, everything else seems good ??? !!! TEST
        event_clicked.destroy

        new_route.category = :instance
        new_route.save
        session[:last_route_id_edited] = new_route.id # used to plant a Class to mark the event in the calendar, so the js can highlight the change and scroll to it.
        cookies.permanent[:last_working_date] = new_route.starts_at.iso8601 # TEST !!!
      end

      head :ok # what ? this
    end
  end

  def refresh_calendar # _________________________________________________________
    @working_week = params[:working_week] ? params[:working_week] : "2015 09 12" #YYYY MM DD
    # p "@working_week = " + @working_week
  end

  def duplicate # ______________________________________________________________

    dup_type = params[:dup_as]

    if request.xhr?

      event_clicked = FullcalendarEngine::Event.find(params[:event_id])
      new_route = event_clicked.route.deep_clone :include => [:drivers, :passengers, :locations]
      new_route.event =  FullcalendarEngine::Event.new({
          :starttime => event_clicked.starttime.iso8601,
          :endtime => event_clicked.endtime.iso8601
      })

      case dup_type.to_s
      when "make_template"
          new_route.category = :template
          new_route.event.all_day = true  # so it shows at top in Fullcalendar, move this to event code !!! ?
          # Turn original into an instance
          event_clicked.route.category = :instance
          new_route.scheduled_instances << event_clicked.route
          event_clicked.save
          # event_clicked.route.modified = false
        when "make_instance"
          if !event_clicked.route.scheduled_instances.any? # still the way to do this ??? !!!, just double check
            new_route.category = :instance
            new_route.event.all_day = false
            event_clicked.route.scheduled_instances << new_route
          end
        when "make_special"
          new_route.category = :special
          new_route.event.all_day = false
          # Might have to not copy the passengers and drivers once there becomes
          # logic validations (like no passenger in 2 cars at same time, etc)
          # Maybe a way to turn on and off validations? so the admin can mess around freely? ???
      end

      new_route.save
      if dup_type.to_s == "make_instance"
        session[:last_route_id_edited] = event_clicked.route.id # keep focus on the instance
        # p "session[:last_route_id_edited] = " + session[:last_route_id_edited] + " and should = " + event_clicked.route.id.to_s
      else
        session[:last_route_id_edited] = new_route.id
      end

      head :ok
    else
    end
  end

  def get_events # _____________________________________________________________

    @calendar_all_day_mode = cookies[:calendar_all_day_mode] ? cookies[:calendar_all_day_mode] : 'routines'
    # p "@calendar_all_day_mode = " + @calendar_all_day_mode
    @working_week = cookies[:last_viewing_moment] ? cookies[:last_viewing_moment] : "2015 09 12" #YYYY MM DD
    events = []

    if (params[:request_type] == "template") && (@calendar_all_day_mode == 'missing_persons')
      # We're hijacking the request for template data here, because now we're overloading the ALLDAY spot in the calendar to also show missing passengers
      # So lets feed it one big fat fake event that contains all the names of the missing passengers for the day!
      missing_persons_by_date = current_user.current_carpool.get_missing_persons(@working_week)

      missing_persons_by_date.each_pair do |date, missing_who_cnt|

        missing_who_cnt.keys.each do |passenger| 
          events << { id: -1,
              title: passenger,
              description: '',
              start: date.iso8601,
              end: date.iso8601,
              allDay: true,
              recurring: false,
              category: 'missing_person',
              className: '',
              has_children: false,
              route_id: 0,
              child_id: ''
            } if !passenger.nil?
        end

      end

    else    
        # Use the Ransack query from Activeadmin
      params[:q] = session[:search]
      @q = current_user.current_carpool.routes.ransack(params[:q])#.include(:)
      # refine by whatever calendar data sources the fullCalendar wants via :request_type (and now it wants the id..)
      # modifiedType = if params[:request_type]
      routes = @q.result.where(:category => Route.categories[params[:request_type]])
      # p "session[:last_route_id_edited] = " + session[:last_route_id_edited].to_s
      routes.each do |route|
        if route.event
          @classNames = []
          @classNames << "CurrentEvent" if (route.id == session[:last_route_id_edited].to_i)

          # if route.is_template?
          #   start_date = route.event.starttime.wday # Need to translate this into current selected week's actual date
          #   end_date = route.event.endtime.wday
          # else
          #   start_date = route.event.starttime.iso8601
          #   end_date = route.event.endtime.iso8601
          # end

          events << { id: route.event.id,
                      title: route.event.title,
                      description: route.event.description || '',
                      start: route.event.starttime.iso8601,
                      end: route.event.endtime.iso8601,
                      allDay: route.event.all_day,
                      recurring: (route.event.event_series_id) ? true : false,
                      category: route.category.to_s,
                      className: @classNames.join(","),
                      has_children: route.scheduled_instances.any?,
                      route_id: route.id,
                      child_id: (route.scheduled_instances.any?) ?  route.scheduled_instances.first.event.id : ''
                    }
        end # if
      end # do
    end # else

    render json: events.to_json
  end
  # ____________________________________________________________________________

end # controller
end
