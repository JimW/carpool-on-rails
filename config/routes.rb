Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


# http://stackoverflow.com/questions/11691169/how-can-i-change-the-default-url-of-activeadmin

# mount FullcalendarEngine::Engine => "/admin/routes"
  # mount FullcalendarEngine::Engine => "/admin/calendar"
  mount FullcalendarEngine::Engine => "/calendar"
  # devise_for :users, ActiveAdmin::Devise.config

  # http://stackoverflow.com/questions/30249740/how-do-i-use-devise-and-activeadmin-for-the-same-user-model
  # http://stackoverflow.com/questions/19537243/routingerror-after-upgrading-activeadmin-to-v-0-6-2
  config = {class_name: 'User'}.merge(ActiveAdmin::Devise.config)
  config[:controllers][:registrations] = "users/registrations"
  config[:controllers][:omniauth_callbacks] = "users/omniauth_callbacks"
  config[:controllers][:invitations] = 'users_invitations' # user_invitations_controller.rb

  devise_for :users, config

  # post '/admin/carpools/reset_calendar' => 'admin/carpools#reset_calendar', as: :admin_carpool_reset_calendar

  # Fixed issues where I could only add a user once..
# http://stackoverflow.com/error?aspxerrorpath=/questions/30249740/how-do-i-use-devise-and-activeadmin-for-the-same-user-model/30270909
  # devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  ActiveAdmin.routes(self)
  get 'welcome/index'

  resources :routes do  
      collection do
        get :get_missing_persons
      end
    end

  namespace :admin do
      resources :users
  end
# For using as an API, issue with simple_token_authentication
# https://github.com/activeadmin/activeadmin/issues/2957
# devise_for :users
#
#  devise_scope :user do
#    namespace :api do
#      namespace :v1 do
#        resources :sessions,      :only => [:create, :destroy]
#        resources :registrations, :only => [:create, :destroy]
#        post "upload" => "app_photos#create"
#      end
#    end
#  end
#
#  devise_for :admin_users, ActiveAdmin::Devise.config
#  ActiveAdmin.routes(self)


  # devise_for :users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self) NOT SURE WHY INSTALL DID THIS>>>
  # https://github.com/activeadmin/activeadmin/issues/2414

  namespace :calendars do
    # namespace :v1 do
      resources :subscription
    # end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  # root to: "admin/routes#index"
  root to: "admin/calendar#index" # This is the only unrestricted page for peons

  # root to: "calendar#index"

  # resources :locations
  # resources :users
  #  root  "home#index"
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
