source 'https://rubygems.org'

# Integrate a message system on top of all the Google stuff !!!
# http://www.sitepoint.com/rails-disco-get-event-sourcing/

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.10'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library, it's managed by rails so just use this vs bower
gem 'jquery-ui-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem "bower-rails", "~> 0.11.0"
gem 'sucker_punch', '~> 2.0'
gem 'aws-sdk', '~> 2'
gem 'phony_rails'

gem 'omniauth-oauth2', '~> 1.3.1' #don't use 1.4.0 broken
# https://github.com/intridea/omniauth-oauth2/issues/81
# crazy..

gem "omniauth-google-oauth2"
gem 'devise', '4.3.0'

gem "rolify"
gem "pundit"
gem 'activeadmin', '~> 1.1.0'
gem 'seed_dump'

# For drag and drop lists (in route locations)
gem 'acts_as_list'
# gem 'activeadmin-sortable'
gem 'best_in_place', '~> 3.1.0'
# gem 'dirty_associations'
#Just using my own from here:
# http://anti-pattern.com/dirty-associations-with-activerecord

# http://staal.io/blog/2013/02/26/mastering-activeadmin/
gem 'chosen-rails' # don't try to take this out until chosen deals with the reference to icons in their css
gem 'just-datetime-picker'
gem 'fullcalendar_engine', path: "vendor/fullcalendar-rails-engine"
# https://github.com/vinsol/fullcalendar-rails-engine/issues/12

# https://github.com/slate-studio/activeadmin-settings

gem 'chronic'
# https://github.com/Baremetrics/calendar

# CLONING ASSOCIATIONS
# https://github.com/moiristo/deep_cloneable
gem 'deep_cloneable', '~> 2.1.1'
# Alternate solution.?
# https://github.com/amoeba-rb/amoeba
# http://www.mariocarrion.com/2015/07/12/amoeba-with-deep-cloning.html

# comparing records for equality:
# https://github.com/TylerRick/active_record_ignored_attributes
# gem "active_record_ignored_attributes"

# https://github.com/twilio/twilio-ruby
# gem 'twilio-ruby', '~> 4.2.1'

# https://github.com/amoeba-rb/amoeba/issues

# http://blog.greenfieldhq.com/2015/04/10/iCal-subscriptions-with-ember-and-rails/
gem 'icalendar'

# Sync with Google Cal API
# http://baugues.com/google-calendar-api-oauth2-and-ruby-on-rails
# gem 'google-api-client', '0.9.27' # pre3'#,:require => 'google/api_client'
gem 'google-api-client', '~> 0.9'
# gem 'google-api-client', '0.10.0' # pre3'#,:require => 'google/api_client'

gem 'base32'

ruby "2.2.6" # had to downgrade for the ironworkers on Heroku, Heroku is fine with 2.2 though..

gem "figaro" # though rails 4.1 now uses secrets.yml, keep production secrets within Env and check that yml file into github
# https://devcenter.heroku.com/articles/getting-started-with-rails4#local-workstation-setup

gem "puma", "3.6.2" # For webserver for Heroku

# Why is this group or any group called development not being picked up by bundler ??? Really?
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug' # REMOVE for RUBYMINE
  gem 'quiet_assets'
  gem "better_errors"
  gem "minitest-rails"
  gem "minitest-reporters"
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'meta_request'
  # gem 'rails-erd'
  gem "lograge"
end

# https://devcenter.heroku.com/articles/getting-started-with-rails4#local-workstation-setup
group :production do
  gem 'rails_12factor' # To enable features such as static asset serving and logging on Heroku
  gem 'pg'
end

# gem 'simple_uuid' # for rfc4122 based event ids as suggested by google calendar v3

# gem 'google-api-client', :require => 'google/api_client'


# gem 'google_calendar'

# Twilio
# https://www.twilio.com/blog/2014/02/twilio-on-rails-integrating-twilio-with-your-rails-4-app.html
# gem 'twilio-ruby', '~> 4.2.1'

# https://github.com/activeadmin/activeadmin/wiki/Auditing-via-paper_trail-(change-history)
# gem 'paper_trail', '~> 4.0.0.rc'

# https://github.com/activeadmin/activeadmin/wiki/Ckeditor-integration
# gem 'ckeditor'

# Graphs
# http://morrisjs.github.io/morris.js/
# http://corygwin.com/post/100806490592/active-admin-custom-report-page

# Rails variables in JS
# https://github.com/gazay/gon


# gem 'active_skin'
# https://github.com/apneadiving/Google-Maps-for-Rails
# gem 'gmaps4rails'

# API stuff
# gem 'rocket_pants', '~> 1.0'
# https://github.com/Sutto/rocket_pants

# https://github.com/alexreisner/geocoder
# gem 'geocoder'
# gem "just-datetime-picker"
# gem "just-time-picker"
# gem 'momentjs-rails'
# gem 'fullcalendar-rails'
# http://www.mikesmithdev.com/blog/jquery-full-calendar/


# useful for a approval/draft process (needed when we start updating users of changes automatically)
# https://github.com/liveeditor/draftsman/issues/30

# gem 'draper', '~> 1.3'
# http://apotomo.de/peters-guide-1.1/introduction.html
# gem 'active_record_union' might have to use this, to allow users to edit their location data
# To get both homes and work_places

# http://railscasts.com/episodes/324-passing-data-to-javascript?view=asciicast
# gem 'gon'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# gem 'seed-fu', '~> 2.3'

# https://github.com/mzaragoza/rails-fullcalendar-icecube
# gem 'fullcalendar-rails'

# gem 'ice_cube'
# gem 'recurring_select' # One of ice_cube's bitches
