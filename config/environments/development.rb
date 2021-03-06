Rails.application.configure do
    # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true 

  # Settings specified here will take precedence over those in config/application.rb.

  # added this to stop all the Google jobs from polluting my logs
  config.active_job.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new("log/#{Rails.env}.log"))
  # https://stackoverflow.com/questions/32045387/how-do-i-filter-or-remove-logging-of-activejob-arguments

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  # config.active_record.migration_error = :page_load
  config.active_record.migration_error = false
  
  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # From rails 4.2 XXX check these are still right for 5.0 XXX for 5.1 too..
  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true
  
  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
  
  # for Devise
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.active_record.logger = nil
  

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.read_encrypted_secrets = false
  
  config.webpacker.check_yarn_integrity = false
  
end
