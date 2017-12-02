
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#timeout

Rack::Timeout.timeout = 20  # seconds
Rack::Timeout.unregister_state_change_observer(:logger) if Rails.env.development?