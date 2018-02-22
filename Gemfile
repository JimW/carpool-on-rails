source 'https://rubygems.org'

# From a fresh 5.1 rails app:
# git_source(:github) do |repo_name|
#   repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
#   "https://github.com/#{repo_name}.git"
# end

# Integrate a message system on top of all the Google stuff !!!
# http://www.sitepoint.com/rails-disco-get-event-sourcing/

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.4'
# gem 'rails', '5.2.0.beta2' # this will force proper puma config for capybara, single thread or something..
  # https://github.com/rails/rails/pull/30638
  # TODO: first deal with any before_save change deprectaions warnings from in 5.1
  
# Use SCSS for stylesheets
gem 'sass-rails'#, '~> 5.0.7'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker

gem 'webpacker'
# gem 'webpacker', github: 'rails/webpacker' # Because webpacker is installing binstubs wrong
# https://github.com/rails/webpacker/issues/995

gem 'graphql', '1.7.9' #1.7.10 broke something # evolving features with Auth are PRO only for $$$, no changelogs.. try and swap out when possible !!!
# https://github.com/rmosolgo/graphql-ruby/issues/1281

# https://github.com/rmosolgo/graphql-ruby

# so try this instead XXX:
# gem 'graphql-client'
# https://github.com/github/graphql-client

# https://www.youtube.com/watch?v=SGkTvKRPYrk
gem 'react_on_rails', '10.1.1' # prefer exact gem version to match npm version

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "awesome_print"

# https://github.com/colszowka/simplecov
gem 'simplecov', :require => false, :group => :test
# gem 'coverband' # https://github.com/danmayer/coverband

group :development, :test do

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem "better_errors"

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'meta_request'

  gem "pry"
  gem "pry-byebug"
  gem "pry-doc"
  gem "pry-rails"
  gem "pry-rescue"
  gem "pry-stack_explorer"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem "spring"
  # gem "spring-commands-rspec"

  # # Color console output
  gem "rainbow"

  # Linters and Security
  gem 'rubocop', '~> 0.52.1', require: false
  gem "ruby-lint", require: false
    # Critical that require: false be set! https://github.com/brigade/scss-lint/issues/278
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "scss_lint", require: false
  # gem 'factory_bot_rails' # prefer to keep it as simple as possible right now, so no..
end

group :test do
  gem "minitest-rails"
  gem "minitest-reporters"
  gem 'minitest-rails-capybara'
  gem "selenium-webdriver"
  
  # gem "chromedriver-helper"
  # or when using wsl install via:
  # http://ngauthier.com/2017/09/rails-system-tests-with-headless-chrome-on-windows-bash-wsl.html

  gem "capybara-screenshot"
  # gem "launchy"
  # gem "capybara-webkit", "1.14.0"
  gem "poltergeist" # have to install some exectuable without source.. holding off testing JS system stuff
  gem "database_cleaner"
  gem "rails_best_practices"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  # gem 'rails-erd'
  gem 'graphiql-rails'
  # gem 'ruby-debug-ide'
  # gem 'debase', '0.2.2.beta14'
end

# Use jquery as the JavaScript library, it's managed by rails so just use this
gem 'jquery-ui-rails', '6.0.1'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.2', group: :doc
gem 'sucker_punch', '~> 2.0'
gem 'aws-sdk', '~> 2'
gem 'phony_rails', '0.14.6'
gem "omniauth-google-oauth2", '0.5.2'
gem 'devise', '4.3.0' 
gem "rolify", '5.1.0'
gem "pundit", '1.1.0'

# ___  Active Admin stuff
gem 'activeadmin', '~> 1.2.1'
# gem 'activeadmin'#, git: 'https://github.com/activeadmin/activeadmin.git'
# gem 'inherited_resources'#, git: 'https://github.com/activeadmin/inherited_resources'
# For drag and drop lists (in route locations):
gem 'acts_as_list', '0.9.10'
gem 'best_in_place', '~> 3.1.1'
gem 'seed_dump','3.2.4'

# gem 'dirty_associations'
# Just using my own from here:
# http://anti-pattern.com/dirty-associations-with-activerecord

# http://staal.io/blog/2013/02/26/mastering-activeadmin/
gem 'chosen-rails'#, '1.5.2' # don't try to take this out until chosen deals with the reference to icons in their css
# Get rid of above XXX

gem 'just-datetime-picker'
# using this for starts_at, ends_at within route model
# https://github.com/mspanc/just-datetime-picker

# gem 'fullcalendar_engine', path: "vendor/fullcalendar-rails-engine"
# https://github.com/vinsol/fullcalendar-rails-engine/issues/12

gem 'chronic'
# https://github.com/Baremetrics/calendar

# CLONING ASSOCIATIONS
# https://github.com/moiristo/deep_cloneable
gem 'deep_cloneable', '~> 2.3.1'
# Alternate solution.?
# https://github.com/amoeba-rb/amoeba
# http://www.mariocarrion.com/2015/07/12/amoeba-with-deep-cloning.html
# https://github.com/amoeba-rb/amoeba/issues

# http://blog.greenfieldhq.com/2015/04/10/iCal-subscriptions-with-ember-and-rails/
gem 'icalendar'

# Sync with Google Cal API
# http://baugues.com/google-calendar-api-oauth2-and-ruby-on-rails
gem 'google-api-client', '~> 0.17.3'
gem 'base32'
gem "figaro" # though rails 4.1 now uses secrets.yml, keep production secrets within Env and check that yml file into github
# https://devcenter.heroku.com/articles/getting-started-with-rails4#local-workstation-setup

# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
gem "puma", "3.11.0" 

# https://devcenter.heroku.com/articles/getting-started-with-rails4#local-workstation-setup
group :production do
  gem 'pg', "0.21" # 1.0 not supported yet by some rails dependency
end

# "to bring sanity to Rails' noisy and unusable, unparsable and, in the context of running multiple processes and servers, unreadable default logging output"
gem "lograge"

gem "rack-timeout"
# https://github.com/heroku/rack-timeout
# all kinds of stuff here related to timeouts.  May need to examine logs under some load to figure out what tweaks are needed XXX

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby "2.4.2" # had to downgrade for the ironworkers on Heroku, Heroku is fine with 2.2 though..

# ______________________________________________________________________________

# gem 'simple_uuid' # for rfc4122 based event ids as suggested by google calendar v3

# gem 'active_skin'
# https://github.com/apneadiving/Google-Maps-for-Rails
# gem 'gmaps4rails'

# https://github.com/alexreisner/geocoder
# gem 'geocoder'
# gem "just-datetime-picker"
# gem "just-time-picker"
# gem 'momentjs-rails'
# gem 'fullcalendar-rails'
# http://www.mikesmithdev.com/blog/jquery-full-calendar/
# https://github.com/mzaragoza/rails-fullcalendar-icecube

# useful for a approval/draft process (needed when we start updating users of changes automatically)
# https://github.com/liveeditor/draftsman/issues/30

# gem 'draper', '~> 1.3'
# http://apotomo.de/peters-guide-1.1/introduction.html
# gem 'active_record_union' might have to use this, to allow users to edit their location data
# To get both homes and work_places

# http://railscasts.com/episodes/324-passing-data-to-javascript?view=asciicast
# gem 'gon'

# gem 'seed-fu', '~> 2.3'

# for easily handling repeated events (schedules)
# gem 'ice_cube'
# gem 'recurring_select' # One of ice_cube's bitches 

gem 'mini_racer', platforms: :ruby