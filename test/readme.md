Wrap these into a rake called db:test:reset or something
bundle exec rake db:drop RAILS_ENV=test
bundle exec rake db:create RAILS_ENV=test
bundle exec rake db:schema:load RAILS_ENV=test

Above is necessary when I start getting duplicate index violation type errors from PG.  Somehow the db does not get cleared upon certain errors, likely related to some bug in rails fixture associations
