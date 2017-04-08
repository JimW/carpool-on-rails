ActiveAdmin.register Location do

menu label: "Locations", priority: 4

config.filters = false
# filter :city

permit_params do
  permitted = [
   :city, :desc, :short_name, :intersectStreet1, :intersectStreet2, :latitude, :longitude, :state, :street, :text, :title, :title_cont_ids,
   resident_ids:[], worker_ids:[], route_ids:[], carpool_ids:[]
   ]
  permitted
end
# ___________________ index ____________________________________________________

index do
  selectable_column
  # id_column
  column "Short Name", sortable: :short_name do |location|
    link_to location.short_name, admin_location_path(location)
  end
  column :title
  column :street
  column :city
  column :actions do |resource|
    links = link_to "  " + I18n.t('active_admin.edit'), edit_resource_path(resource) #if current_user.has_any_role? :admin, { :name => :manager, :resource => current_user.current_carpool }
    links += link_to "  " + I18n.t('active_admin.delete'), resource_path(resource), :method => :delete #if current_user.has_any_role? :admin, { :name => :manager, :resource => current_user.current_carpool }
    links
  end if current_user.has_any_role? :admin, { :name => :manager, :resource => current_user.current_carpool }
end
# ___________________ show _____________________________________________________
show do

  attributes_table do

    row :short_name do |location|
      best_in_place location, :short_name, :as => :input,:url =>[:admin,location]
    end
    row :title do |location|
      best_in_place location, :title, :as => :input,:url =>[:admin,location]
    end
    row :city do |location|
      best_in_place location, :city, :as => :input,:url =>[:admin,location]# :as => :select#, :collection => Location.possibleLocations.map { |loc| [loc,loc] }, :path =>[:admin,location]
    end
    if location.carpools.any?
        table_for location.carpools do
          column "Carpools" do |cp|
            li cp.title
          end
        end  # end
    end

    if location.residents.any?
        table_for location.residents do
          column "Residents:" do |user|
            li user.first_name
          end
        end  # end
    end
    if location.workers.any?
      table_for location.workers do
        column "Workplace for:" do |user|
          li user.first_name
        end
      end  # end
    end
    if location.routes.any?
        table_for location.routes do
          column "Route References:" do |route|
            route.title
          end
        end
    end
  end

end # show

# _____________________ form ___________________________________________________
form do |f|
  f.semantic_errors *f.object.errors.keys
  f.inputs "Details:" do
    f.input :title
    f.input :short_name
    f.input :street
    f.input :city
  end
  f.inputs "Carpools:" do
    f.inputs :carpools, :as => :multiple_select#, collection: policy_scope(Carpool)#, collection: current_user.carpools.all  #=> current_user.carpools #:collection => policy_scope(Carpool)#, :required => true
  end
  f.actions
end

# ______________________________ controller ____________________________________
controller do

  def update(options={}, &block)
    super do |success, failure|
      block.call(success, failure) if block
      success.html { redirect_to collection_path }
      failure.html { render :edit }
    end
  end

  def new(options={}, &block)
    @location = Location.new
    @location.carpools << current_user.current_carpool
    new!
  end

  def create(options={}, &block)
    super do |success, failure|
      block.call(success, failure) if block
      success.html { redirect_to collection_path }
      failure.html { render :edit }
    end
  end

  def index
    @page_title = "Locations for #{current_user.current_carpool.title_short}"
    index!
  end

end # controller
# ____________________________________________________________________________

end # Main
