module Calendars

  # NOTE: This works but is no longer used. Once upon a time, I allowed ical users to subscribe to a feed.
  # But I did'nt want to be hit periodically, especially when there is no way to set the refresh frequency for ical feeds within the subscription link.
  # I didn't want hundreds or thousands of people hitting the server, looking for changes every 1 minute, even if cached..
  # Better to allow google to do it's thing.  Apple calendar integration seems more client based, so a web solution for their tech was not obvious.

    class SubscriptionController < ApplicationController # API::BaseController
      # skip_before_action :some_kind_of_auth, only: [:index]
        include ActionController::MimeResponds

        def index

          # Passing enum values to where isn't supported prior to Rails 5.
          # The following is the only way I could get this to work
          routes = Route.arel_table
          @routes = Route.where(
                                routes[:category].eq(1).
                                or(routes[:category].eq(2)).
                                or(routes[:category].eq(3))
                               )

          calendar = Icalendar::Calendar.new

          # Paramaterize these values within some setup file !!!
          # Not showing up in ical on Yosemite !!!
          calendar.x_wr_caldesc "serving the <xyz> region"
          calendar.x_wr_calname = "dTech Carpool"
          calendar.prodid = "xx.com"
          calendar.x_wr_timezone = "America/Los_Angeles"
          calendar.x_published_ttl = "PT5M"

          @routes.each do |route|
            calendar.add_event(route.event.to_ics)
          end
          respond_to do |format|
            format.ics {
              # p calendar.to_ical
              render text: calendar.to_ical
            }
          end
        end
      end
  # end
end


# !!!
#  Need to do this for each type of user and then create a sharable link via something like:
# require "digest"
# Digest::SHA512.hexdigest("#{created_at}#{user_id}.mysupersonicsecretSALT")

# http://railscasts.com/episodes/350-rest-api-versioning?view=asciicast

# http://jes.al/2013/10/architecting-restful-rails-4-api/

# self documenting based off of tests
# https://github.com/zipmark/rspec_api_documentation

# http://collectiveidea.com/blog/archives/2013/06/13/building-awesome-rails-apis-part-1/
# MUST READ
# https://labs.kollegorna.se/blog/2015/04/build-an-api-now/
# https://github.com/kollegorna/active_hash_relation
# BEGIN:VCALENDAR
# VERSION:2.0
# PRODID:-//My Company//NONSGML Event Calendar//EN
# URL:http://my.calendar/url
# NAME:My Calendar Name
# X-WR-CALNAME:My Calendar Name
# DESCRIPTION:A description of my calendar
# X-WR-CALDESC:A description of my calendar
# TIMEZONE-ID:Europe/London
# X-WR-TIMEZONE:Europe/London
# REFRESH-INTERVAL;VALUE=DURATION:PT12H
# X-PUBLISHED-TTL:PT12H
# COLOR:34:50:105
# CALSCALE:GREGORIAN
# METHOD:PUBLISH

# https://blog.nop.im/entries/calendar-feed-with-rails
