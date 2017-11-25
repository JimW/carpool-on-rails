# https://github.com/zquestz/omniauth-google-oauth2#fixing-protocol-mismatch-for-redirect_uri-in-rails
# OmniAuth.config.full_host = Rails.env.production? ? 'https://carpool.xx.com' : 'http://localhost:3000'
OmniAuth.config.full_host = ENV['SITE_ROOT_URL']