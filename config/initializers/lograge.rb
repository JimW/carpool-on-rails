# config/initializers/lograge.rb
# OR
# config/environments/production.rb
Rails.application.configure do
  
  config.lograge.enabled = true

  # If you're using Rails 5's API-only mode and inherit from ActionController::API:
  # config.lograge.base_controller_class = 'ActionController::API'
  
end