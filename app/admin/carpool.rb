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
   ]
  # permitted <<    #:other if resource.something?
  permitted
end

filter :locations
filter :users

sidebar :help do
  "Need help? Email me at help@example.com"
end
# https://github.com/activeadmin-plugins/active_admin_sidebar

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
    links = link_to "  " + I18n.t('active_admin.edit'), edit_resource_path(resource) if (resource.title_short != "Lobby") && (current_user.has_any_role? :admin, { :name => :manager, :resource => current_user.current_carpool })
    links += link_to "  " + I18n.t('active_admin.delete'), resource_path(resource), :method => :delete if ((current_user.has_any_role? :admin) && (resource.title_short != "Lobby"))
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
    row :publish_to_gcal if (carpool.title_short != "Lobby")
    row :google_calendar_id if carpool.publish_to_gcal
  end

  panel "Locations" do
    table_for carpool.locations do
      column "Locations" do |loc|
        li loc.title
      end
    end
  end
  panel "Members" do
    if carpool.drivers.any?
        table_for carpool.drivers do
          column "Drivers" do |user|
            li user.full_name
          end
        end  # end
    end
    if carpool.passengers.any?
      table_for carpool.passengers do
        column "Passengers" do |user|
          li user.full_name
        end
      end  # end
    end
  end

end # show

# _____________________ form ___________________________________________________

form do |f|
  f.semantic_errors *f.object.errors.keys
  f.inputs "Details:" do
    li carpool.title
    f.input :organization if current_user.has_any_role? :admin
  end if (carpool.title_short == "Lobby") # right now the code is dependent on "Lobby" as it's title_short

  f.inputs "Details:" do
    f.input :title
    f.input :title_short
    f.input :organization if current_user.has_any_role? :admin
    f.input :publish_to_gcal, :label => "Enable Google Calendar", as: :boolean if (current_user.has_any_role? :admin)
    f.input :google_calendar_id, input_html: { disabled: true } if carpool.publish_to_gcal
  end if (carpool.title_short != "Lobby")

  f.inputs "Members:" do
    f.input :drivers, :as => :select, :collection => object.organization.lobby.users.map{|u| [u.full_name,u.id]}  #:as => :check_box#, :collection => User.all_can_drive.all.map{|u| [u.short_name,u.id]}
    f.input :passengers, :as => :select, :collection => object.organization.lobby.users.map{|u| [u.full_name,u.id]}
  end if (current_user.has_any_role? :admin)

  # f.inputs "Locations:" do
  #   f.input :locations, :as => :select, :collection => Location.all.map{|loc| [loc.short_name,loc.id]}  #:as => :check_box#, :collection => User.all_can_drive.all.map{|u| [u.short_name,u.id]}
  # end # form

  f.actions
end

controller do

  def update(options={}, &block)  # ____________________________________________
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
