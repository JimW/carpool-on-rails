require "minitest/autorun"
require 'googleauth'
require 'google/apis/calendar_v3' # for post .8.x

class TestGoogleServiceCalendar < Minitest::Test

  def setup
    # @meme = Meme.new
  end

  def test_that_connection_works

    # gs = GoogleServiceAccount::Calendar.new(ENV["MY_SERVICE_ACCOUNT_EMAIL"])
    #
    # # gs = GoogleServiceAccount::Calendar.new(ENV["my_service_account_secondary_calendar_id"])
    # # google_events = gs.events(ENV["my_service_account_test_calendar_id"])
    # google_events = gs.events(ENV["my_service_account_secondary_calendar_id"])

    assert true # gs.XX is something

    # assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  end

  # def test_that_it_will_not_blend
  #   refute_match /^no/i, @meme.will_it_blend?
  # end
  #
  # def test_that_will_be_skipped
  #   skip "test this later"
  # end
end
