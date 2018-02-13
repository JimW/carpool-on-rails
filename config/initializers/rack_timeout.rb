
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#timeout

Rack::Timeout.timeout = 20  # seconds
Rack::Timeout.unregister_state_change_observer(:logger) if Rails.env.development?

# https://github.com/heroku/rack-timeout
Rack::Timeout.service_timeout = 30  # seconds
# service_timeout:   15
# wait_timeout:      30
# wait_overtime:     60
# service_past_wait: false