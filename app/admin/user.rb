ActiveAdmin.register User do

  menu label: "Members", priority: 3 # Make a seperate page for Passengers vs Drivers ?

  permit_params do
    permitted = [
    :email, :first_name, :last_name, :name, :password, :password_confirmation, :current_password, :can_drive, :home_phone, :mobile_phone, :mobile_phone_messaging,
    :current_carpool_id,
    :current_organization_id,
    :subscribe_to_gcal,
    organization_users_attributes: [:id, :organization_id, :user_id, :personal_gcal_id ],
    organization_ids:[],
    home_ids:[],
    work_place_ids:[],
    driver_route_ids:[],
    driver_routine_route_ids:[],
    passenger_routine_route_ids:[],
    passenger_route_ids:[],
    role_ids:[],
    driver_membership_ids:[],
    passenger_membership_ids:[],
    carpool_role_ids:[],
    ]
    permitted
  end

  config.filters = false # ...simplicity
  # filter :carpools, collection: proc { policy_scope(Carpool) } # if: proc { current_user.is_admin? || current_user.has_role?(:manager, current_user.current_carpool) }
  # filter :email
  # filter :first_name
  # filter :can_drive, as: :radio, collection: [["Yes", true], ["No", false]], label: 'Available as Driver:'

  # Invitation Stuff ________________________________  OLD AND OUTDATED and not used _____________________________
  # action_item do
  #   link_to 'Invite New User', new_invitation_admin_users_path
  # end

  # collection_action :new_invitation do
  # 	@user = User.new
  # end
  #
  # collection_action :send_invitation, :method => :post do
  # 	@user = User.invite!(params[:user], current_user)
  # 	if @user.errors.empty?
  # 		flash[:success] = "User has been successfully invited."
  # 		redirect_to admin_users_path
  # 	else
  # 		messages = @user.errors.full_messages.map { |msg| msg }.join
  # 		flash[:error] = "Error: " + messages
  # 		redirect_to new_invitation_admin_users_path
  # 	end
  # end

  # collection_action :import_csv, method: :post do
  #   # Do some CSV importing work here...
  #   redirect_to collection_path, notice: "CSV imported successfully!"
  # end

  batch_action :unsubscribe do |ids|
    ids.each do |id|
      @user = User.find(id)
      @user.subscribe_to_gcal = false
      @user.save
    end
    redirect_to collection_path, alert: "Users were unsubscribed!"
  end

  batch_action :subscribe do |ids|
    ids.each do |id|
      @user = User.find(id)
      @user.subscribe_to_gcal = true
      @user.save
    end
    redirect_to collection_path, alert: "Users were subscribed! Google users will receive an email from google informing them"
  end


  #  ______________________________   _______________________________________________

  # member_action :set_current_carpool, method: :get do
  # 	# resource.set_current_carpool!
  # 	redirect_to resource_path, notice: "Current Carpool Set!"
  # end

  # ___________________ index ____________________________________________________

  index do
    selectable_column
    id_column if current_user.has_any_role? :admin
    column "Name", sortable: :last_name do |user|
      link_to user.full_name, admin_user_path(user)
    end
    column :email, sortable: false if (ENV['DEMO_MODE'].nil?)
    column "Mobile #", :mobile_phone, sortable: false  if (ENV['DEMO_MODE'].nil?)
    column "gCal", sortable: :subscribe_to_gcal do |user|
        user.subscribe_to_gcal? ? status_tag( "Yes", :ok ) : status_tag( "No" )
    end
    column "Status", sortable: :active do |user|
      user_details = user.carpool_users.includes(:carpool).where(carpool_id: current_user.current_carpool.id).first 
      user_details.is_active ? status_tag( "Active", :ok ) : status_tag( "Resting" )
    end
    column "Can Drive?", sortable: :can_drive do |user|
        user.can_drive? ? status_tag( "Yes", :ok ) : status_tag( "No" )
    end
    column "Participation" do |user|
      user_details = user.carpool_users.includes(:carpool).where(carpool_id: current_user.current_carpool.id).first 
      status_tag( "Driver", :ok ) if user_details.is_driver
      status_tag( "Passenger", :ok ) if user_details.is_passenger
      status_tag( "Observer", :ok ) if !user_details.is_passenger && !user_details.is_driver
    end

    column :actions do |resource|
      # links = link_to I18n.t('active_admin.view'), resource_path(resource)
      links = link_to "  " + I18n.t('active_admin.edit'), edit_resource_path(resource) #if current_user.has_any_role? :admin, { :name => :manager, :resource => current_user.current_carpool }
      links += link_to "  " + I18n.t('active_admin.delete'), resource_path(resource), :method => :delete if current_user.has_role? :admin
      links
    end if current_user.has_any_role? :admin, { :name => :manager, :resource => current_user.current_carpool }

  end

  # csv do
  #   column :first_name
  #   column :last_name
  #   column :mobile_phone
  #   column :email
  #   # column('BODY', humanize_name: false) # preserve case
  # end
  # ___________________ show _____________________________________________________

  show do
    attributes_table do
      row :email do |user|
        best_in_place user, :email, :as => :input,:url =>[:admin,user] if (ENV['DEMO_MODE'].nil?)
      end
      row :first_name do |user|
        best_in_place user, :first_name, :as => :input,:url =>[:admin,user]
      end
      row :last_name do |user|
        best_in_place user, :last_name, :as => :input,:url =>[:admin,user]
      end
      row :home_phone do |user|
        best_in_place user, :home_phone, :as => :input,:url =>[:admin,user] if (ENV['DEMO_MODE'].nil?)
      end
      row :mobile_phone do |user|
        best_in_place user, :mobile_phone, :as => :input,:url =>[:admin,user] if (ENV['DEMO_MODE'].nil?)
      end
      # row :mobile_phone_messaging do |user|
      #   best_in_place user, :mobile_phone_messaging, :as => :checkbox,:url =>[:admin,user]
      # end
      # row :can_drive do |user|
      #   best_in_place user, :can_drive, :as => :checkbox,:url =>[:admin,user]
      # end
      row :can_drive
      row :current_carpool
      # row :current_organization 

    # Taking these out for 1st phase, for simplicity.. plus the relationships aren't right, Routine passengers showing up within special
      if user.homes.any?
          table_for user.homes do
            column "Homes:" do |loc|
              li loc.title
            end
          end  # end
      end
      if user.work_places.any?
        table_for user.work_places do
          column "Workplaces:" do |loc|
            li loc.title
          end
        end  # end
      end
      row :subscribe_to_gcal

      row "Google Sync Select" do
        link_to("Click here to give you devices access to the shared Carpool calendars)", "https://calendar.google.com/calendar/syncselect")
      end if user.subscribe_to_gcal

    end

    panel "Personalized Google Calendars" do
      table_for user.organization_users do |org_user|
        column "Organization" do |x|
          x.organization.title
        end
        column "Privately Shared Calendar ID" do |x|
          x.personal_gcal_id
        end

      end
    end if user.subscribe_to_gcal

    panel "Participation" do

      user_carpools_details = user.carpool_users.includes(:carpool)#.where(carpool_id: user.current_carpool.id)
      table_for user_carpools_details do
        column "Carpool Name" do |user_detail|
          span user_detail.carpool.title 
        end
        column "Available as" do |user_detail| 
          span user_detail.is_driver ? status_tag( "Driver", :ok ) : status_tag(nil) if user_detail.is_driver
          span user_detail.is_passenger ? status_tag( "Passenger", :ok ) : status_tag( "" ) if user_detail.is_passenger
          span status_tag( "Observer", :ok ) if !user_detail.is_passenger && !user_detail.is_driver
        end
        column "Status" do |user_detail|
          span user_detail.is_active ? status_tag( "Active", :ok ) : status_tag( "Resting" )
        end
      end 
    end

      panel "Routes" do
      table_for user.driver_routine_routes do
        column "As Routine Driver" do |route|
          li route.title_for_admin_ui
        end
      end  if user.driver_routine_routes.any?

      table_for user.driver_routes do
        column "As Driver" do |route|
          li route.title_for_admin_ui
        end
      end  if user.driver_routes.any?

      table_for user.passenger_routine_routes do
        column "As Routine Passenger" do |route|
          li route.title_for_admin_ui
        end
      end if user.passenger_routes.any?

      table_for user.passenger_routes do
        column "As Passenger" do |route|
          li route.title_for_admin_ui
        end
      end if user.passenger_routes.any?
    end
    
  end
  # _____________________ form ___________________________________________________

  form do |f|
    f.inputs "Details" do
      f.input :subscribe_to_gcal, :value => false, :as => :boolean,
          :hint => "disabling will delete all of " + user.first_name+ "'s carpool calendars" if current_user.is_admin? || resource == current_user
      f.input :email if (ENV['DEMO_MODE'].nil?)
      f.input :first_name
      f.input :last_name
      f.input :home_phone if (ENV['DEMO_MODE'].nil?)
      f.input :mobile_phone if (ENV['DEMO_MODE'].nil?)
      # f.input :mobile_phone_messaging, :value => true
      f.input :password
      f.input :password_confirmation
      f.input :current_carpool, :as => :radio, :collection => user.carpools.map{|cp| [cp.title_short,cp.id]}#, :as => :input,:url =>[:admin,user]
      f.input :can_drive, :value => false, :as => :boolean, :hint => "changing will remove all driver/passenger assignments"

      # f.input :current_organization, :as => :radio, :collection => user.organizations.map{|org| [org.title_short,org.id]} if current_user.is_admin? # change here will invalidate current_carpool

      # user.carpools.each do |carpool|
      #   f.input :roles, as: :check_boxes, :for => carpool, :label => carpool.title_short, :collection => Carpool.find_roles#, name: carpool.title_short
      # end

      # Could not format this nice in ActiveAdmin, I want to React a lot of this stuff anyway..
      # user_details = user.carpool_users.includes(:carpool).where(carpool_id: user.current_carpool.id).first
      # f.inputs "Participation in #{user_details.carpool.title}" do
      #   f.fields_for user_details do |user_detail|
      #     user_detail.input  :is_active, :label => "Active", 
      #                                     :hint => "disabling prevents adding to new routes" 
      #     user_detail.input  :is_driver, :label => "Available as Driver" 
      #                                     # :hint => "changing willSHOULD remove all " + current_user.first_name+ "'s driver assignments" 
      #     user_detail.input :is_passenger, :label => "Available as Passenger" 
      #                                       # :hint => "changing willSHOULD remove all " + current_user.first_name+ "'s passenger assignments" 
      #   end if current_user.is_admin? || resource == current_user
      # end
  
    end

    f.inputs "Access Rights" do

      f.input :roles, :as => :select # How to restrict to only one option !!!

      # Clean all this up !!!

      # Global Roles
      # f.input :roles, as: :check_boxes, label: "Global:", :collection => Role.global if current_user.has_role?(:admin)

      # Should add Roles per Carpool, so a member can be a Manager of one, while having no rights for another !!!

      # Carpool Roles, loop through each assigned carpool, what about making driver a role.. on Carpool and Route..???
      # current_user.carpools.each do |carpool|
        # f.input :roles, as: :check_boxes, :for => carpool, :label => carpool.title_short, :collection => Carpool.find_roles#, name: carpool.title_short
      # end

        # f.inputs :carpool_role_ids, as: :check_boxes, :for => carpool.title_short, name: carpool.title_short, :label => carpool.title_short, :collection => Carpool.find_roles

      # end
      #  f.input :roles, as: :check_boxes, :for => :carpool, :label => "Carpool:", :collection => Carpool.find_roles, name: "Carpool"
    end if current_user.has_role?(:admin)
    f.actions
  end

  controller do # ______________________________ controller ______________________

    def update(options={}, &block)
      # Allow form to be submitted without a password
      if params[:user][:password].blank?
        params[:user].delete "password"
        params[:user].delete "password_confirmation"
      end
      super do |success, failure|
        block.call(success, failure) if block
        success.html { render :view  }
        failure.html { render :edit }
      end
    end # update

    def index
      @page_title = "Members of #{current_user.current_carpool.title_short}"
      index!
    end

    def create(options={}, &block)
      @user = User.new(permitted_params[:user])
      @user.current_carpool = current_user.current_carpool
      @user.organizations << current_user.current_carpool.organization

      if @user.can_drive
        @user.driver_memberships << current_user.current_carpool
      else
        @user.passenger_memberships << current_user.current_carpool
      end

      super do |success, failure|
        block.call(success, failure) if block
        success.html { redirect_to collection_path }
        failure.html { render :edit }
      end
    end # create

    def edit
      @user = User.find(permitted_params[:id])
      @id = @user.id
    end

    def destroy(options={}, &block)
      @user = User.find(permitted_params[:id])
      # @user.carpools.destroy(current_user.current_carpool) # Why not trigerring carpool_user..?
      carpool_user_detail = @user.carpool_users.includes(:carpool).where(carpool_id:current_user.current_carpool.id).first
      @user.carpool_users.destroy(carpool_user_detail)

      if current_user.current_carpool.is_lobby?
        @user.destroy
        flash[:notice] = "Member removed from system"
      else 
        @user.reset_current_carpool if (@user.current_carpool.title == current_user.current_carpool.title)
        flash[:notice] = @user.full_name + " removed from " + current_user.current_carpool.title
      end

      redirect_to collection_path
    end

  end
end
