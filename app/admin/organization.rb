ActiveAdmin.register Organization do

menu label: "Organizations", priority: 6
config.filters = false
config.batch_actions = false

actions :all, :except => [:destroy, :new]

permit_params do
  permitted = [
   :title, :title_short, :description,
    user_ids:[],
    carpool_ids:[],
   ]
  permitted
end
index do
  # id_column
  column :title
  column :title_short
  column :description
  actions
end

# _____________________ form ___________________________________________________
form do |f|
  f.semantic_errors *f.object.errors.keys
  f.inputs "Details:" do
    f.input :title
    f.input :title_short
    f.input :description
  end
  # f.inputs "Associations:" do
  #   f.inputs :carpools, :as => :multiple_select#, :required => true
  #   f.inputs :users, :as => :multiple_select#, :required => true
  # end
  f.actions
end

end
