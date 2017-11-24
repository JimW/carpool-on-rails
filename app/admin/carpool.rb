ActiveAdmin.register Carpool do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
menu label: "Carpools", priority: 5
config.batch_actions = false

permit_params do
  permitted = [
    :title, :title_short, :google_calendar_id, :description, :organization_id, :title_cont_ids, :google_calendar_share_link,
    :publish_to_gcal,
    passenger_ids:[],
    driver_ids:[],
    location_ids:[],
    active_user_ids:[]
  ]
  # permitted <<    #:other if resource.something?
  permitted
end

config.filters = false

# ___________________ index ____________________________________________________
index do
  selectable_column
  column "Title" do |carpool|
    link_to carpool.title, resource_path(carpool)
  end
  column :title_short
  column :publish_to_gcal
  column "Org", sortable: :organization do |carpool|
    link_to carpool.organization.title_short, admin_organization_path(carpool.organization.id)
  end

  column :actions do |resource|
    links = link_to "  " + I18n.t('active_admin.edit'), edit_resource_path(resource) if (!resource.is_lobby?) && (current_user.has_any_role? :admin, { :name => :manager, :resource => current_user.current_carpool })
    links += link_to "  " + I18n.t('active_admin.delete'), resource_path(resource), :method => :delete if ((current_user.has_any_role? :admin) && (!resource.is_lobby?))
    links
  end
end

# ___________________ show _____________________________________________________
show do
  attributes_table do
    row :title do |carpool|
      best_in_place carpool, :title, :as => :input,:url =>[:admin,carpool]
    end
    row :title_short do |carpool|
      best_in_place carpool, :title_short, :as => :input,:url =>[:admin,carpool]
    end
    row :organization
    row :publish_to_gcal if !carpool.is_lobby?
    row :google_calendar_id if carpool.publish_to_gcal
  end

  panel "Members" do
  #  users = carpool.users.includes(:carpool_users)#.order(:full_name) #.sort_by{ |u| -u.carpool_users[:is_driver] }
  #  p users.count
   table_for carpool.users do
      column :full_name
      column "status" do |u|
        user_detail = u.carpool_users.where(carpool_id: carpool.id).first
        user_detail.is_active ? status_tag( "Active", class: "ok" ) : status_tag( "Resting" )
      end
      column "participation" do |u|
        user_detail = u.carpool_users.where(carpool_id: carpool.id).first
        status_tag( "Driver", class: "ok" ) if user_detail.is_driver
        status_tag( "Passenger", class: "ok" ) if user_detail.is_passenger
        status_tag( "?", class: "ok" ) if (!user_detail.is_passenger && !user_detail.is_driver)
      end
    end

  end

  panel "Locations" do
    table_for carpool.locations do
      column "Locations" do |loc|
        span loc.title
      end
    end
  end

end # show

# _____________________ form ___________________________________________________

form do |f|
  f.semantic_errors *f.object.errors.keys
  f.inputs "Details:" do
    li carpool.title
    f.input :organization if current_user.has_any_role? :admin
  end if carpool.is_lobby? # right now the code is dependent on LOBBY as it's title_short

  f.inputs "Details:" do
    f.input :publish_to_gcal, :label => "Enable Google Calendar", as: :boolean if (current_user.has_any_role? :admin) && (!f.object.new_record?)
    f.input :google_calendar_id, input_html: { disabled: true } if carpool.publish_to_gcal
    f.input :title
    f.input :title_short, :hint => "keep it short so it looks good within mobile calendar apps"
    f.input :organization if current_user.has_any_role? :admin
  end if !carpool.is_lobby?

  f.inputs "Members:" do
    f.input :drivers, :as => :select, :collection => User.all_can_drive.in_lobby.map{|u| [u.full_name,u.id]}, :hint => "can be assigned as drivers, must have 'can drive' set"   #:as => :check_box#, :collection => User.all_can_drive.all.map{|u| [u.short_name,u.id]}
    f.input :passengers, :as => :select, :collection => User.in_lobby.map{|u| [u.full_name,u.id]}, :hint => "can be assigned as passengers"
    f.input :active_users, :as => :select, :collection => User.in_lobby.map{|u| [u.full_name,u.id]}, :hint => "will be available when adding to routes"
  end if !f.object.new_record?

  # f.inputs "User Participation" do
  #   f.has_many :users, heading: false, new_record: false do |user|
  #     user.inputs do
  #       u = user.object
  #       # user.template.concat(Arbre::Context.new do
  #       #   li "#{user.object.full_name}"    end.to_s)
  #       # Does not work.., need to replace all this stuff with more modern React..
  #       #  li u.full_name #do
  #       user_details = u.carpool_users.includes(:carpool).where(user_id: u.id).first
  #       user.fields_for user_carpool_details do |carpool_user|
  #         carpool_user.input  :is_active, :label => "Active"
  #         carpool_user.input  :is_driver, :label => "Available as Driver"
  #         carpool_user.input :is_passenger, :label => "Available as Passenger"
  #       end
  #     end
  #   end
  # end if current_user.is_admin? || resource == current_user

  # f.inputs "Active Status:" do

  #   # f.fields_for :users, heading: false, new_record: false do |user|
  #   # f.fields_for :unique_members_statuses do |member_attr|
  #   # f.inputs :unique_members_statuses do |member_attr|

  #   # f.inputs :unique_members do |member_attr|
  #   f.has_many :users, heading: false, new_record: false do |user|

  #       # members_details = member_attr.object.all
  #     # users = Users.where(id: member_attr.object.id)

  #     user.fields_for :carpool_users do |member|
  #         # user.inputs "#{user.object.try!(:routes).try!(:count)}" do

  #       # user.input :is_active, as: :boolean#, :label => "#{user.object.full_name}"
  #       # if member.object.carpool_id = f.object.id
  #         # user.input :is_active#, :label => "#{user.object.full_name}", as: :boolean
  #       # end
  #     end
  #   end
  # end if (current_user.has_any_role? :admin) #&& (!f.object.new_record?)

  # f.inputs "Locations:" do
  #   f.input :locations, :as => :select, :collection => Location.all.map{|loc| [loc.short_name,loc.id]}  #:as => :check_box#, :collection => User.all_can_drive.all.map{|u| [u.short_name,u.id]}
  # end # form

  f.actions
end

 # _____________________ controller ___________________________________________________

controller do

  def create(options={}, &block)

    @carpool = Carpool.new(permitted_params[:carpool])
    @carpool.users << current_user
    @carpool.save

    current_user.current_carpool = @carpool

    super do |success, failure|
      block.call(success, failure) if block
      success.html { redirect_to collection_path }
      failure.html { render :edit }
    end
  end # create

  def update(options={}, &block)  # ____________________________________________

  # Deals with updating carpool_user's attributes

  @carpool = Carpool.find(params[:id])

    driver_ids = params[:carpool][:driver_ids].reject(&:empty?).map{ |i| i.to_i}
    passenger_ids = params[:carpool][:passenger_ids].reject(&:empty?).map{|i| i.to_i}
    active_user_ids = params[:carpool][:active_user_ids].reject(&:empty?).map{|i| i.to_i}

    exhisting_carpool_user_ids = @carpool.user_ids.map{|i| i.to_i}

    # Predetermine ids for various tasks for updating within carpool_user
    driver_add_ids = driver_ids - @carpool.driver_ids
    driver_remove_ids = @carpool.driver_ids - driver_ids
    passenger_add_ids = passenger_ids - @carpool.passenger_ids
    passenger_remove_ids = @carpool.passenger_ids - passenger_ids
    active_user_add_ids = active_user_ids -  @carpool.active_user_ids
    active_user_remove_ids = @carpool.active_user_ids - active_user_ids

    # Consolidate all ids that need to be processed
    user_ids_to_process = exhisting_carpool_user_ids | driver_add_ids | passenger_add_ids | active_user_add_ids

    users_to_process = User.where(id: user_ids_to_process)
    users_to_process.each do |u|

      @carpool.users << u if !@carpool.users.exists?(u.id)

      if @carpool.users.exists?(u.id)
        carpool_user = u.carpool_users.where(carpool_id: @carpool.id).first
        if carpool_user # otherwise the users is new, so let the normal super.do do

          carpool_user.is_driver = true if driver_add_ids.include?(u.id)
          carpool_user.is_driver = false if driver_remove_ids.include?(u.id)
          carpool_user.is_passenger = true if passenger_add_ids.include?(u.id)
          carpool_user.is_passenger = false if passenger_remove_ids.include?(u.id)
          carpool_user.is_active = true if active_user_add_ids.include?(u.id)
          carpool_user.is_active = false if active_user_remove_ids.include?(u.id)

          carpool_user.save if carpool_user.changed?

          params[:carpool].delete(:driver_ids)
          params[:carpool].delete(:passenger_ids)
          params[:carpool].delete(:active_user_ids)
        end
      end
    end

    super do |success, failure|
      block.call(success, failure) if block
      success.html { render :view  }
      failure.html { render :edit }
    end
  end

  def destroy(options={}, &block)  # ____________________________________________

    @carpool = Carpool.where(id: params[:id]).first!
    @carpool.reset_users_current_carpools

    super do |success, failure|
      block.call(success, failure) if block
      success.html { render :view  }
      failure.html { render :edit }
    end
  end

end

end
