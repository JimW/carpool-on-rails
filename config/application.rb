require_relative 'boot'

require 'rails/all'
require 'devise'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CarPool
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 5.1

    # Enable per-form CSRF tokens. Previous versions had false.
    config.action_controller.per_form_csrf_tokens = false

    # Enable origin-checking CSRF mitigation. Previous versions had false.
    config.action_controller.forgery_protection_origin_check = false

    # Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
    # Previous versions had false.
    ActiveSupport.to_time_preserves_timezone = true

    # Require `belongs_to` associations by default. Previous versions had false.
    config.active_record.belongs_to_required_by_default = false
    # XXX When set to true and the seeding will fail because of some belongs_to somewhere.  And then the admin role won't work.

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.


    # _______ Rails 5 stuff:
    # http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0
    # config.active_record.belongs_to_required_by_default = true
    # config.action_controller.per_form_csrf_tokens = true
    # config.action_controller.forgery_protection_origin_check = true
    # config.action_mailer.deliver_later_queue_name = :new_queue_name
    # config.action_mailer.perform_caching = true
    # config.active_record.dump_schemas = :all
    # config.ssl_options = { hsts: { subdomains: true } }
    # ActiveSupport.to_time_preserves_timezone = false  
    
    # https://hackhands.com/rails-nameerror-uninitialized-constant-class-solution/
    config.autoload_paths += %W(#{config.root}/lib)
    
        # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
        # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
        config.time_zone = 'Pacific Time (US & Canada)'
        config.active_job.queue_adapter = :sucker_punch
    
        # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
        # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
        # config.i18n.default_locale = :de
    
        # config.serve_static_assets = true
        # doing ABOVE instead via gem 'rails_12factor', group: :production
    
        # config.quiet_assets = false;
        # If you need to supress output for other paths you can do so by specifying:
        # config.quiet_assets_paths << '/silent/'
    
        # Fine Tuning !!! Still not getting right-click icons for each option to show up in production, thought precompile would help..
        # https://coderwall.com/p/6bmygq/heroku-rails-bower
        # Explicitly register the extensions we are interested in compiling
        config.assets.precompile.push(Proc.new do |path|
          File.extname(path).in? [
            '.html', '.erb', '.haml',                 # Templates
            '.png',  '.gif', '.jpg', '.jpeg', '.svg', # Images
            '.eot',  '.otf', '.svc', '.woff', '.ttf', '.woff2' # Fonts
          ]
        end)
        # config.assets.precompile += %w( .svg .eot .woff .ttf )
        config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')

        end
end
