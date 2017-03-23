require 'test_helper'

class GoogleServiceCalendarTest < ActiveSupport::TestCase

  # Should create the test calendar as part of the test sequence

  test "connection" do

    key = OpenSSL::PKey::RSA.new ENV['MY_SERVICE_ACCOUNT_KEY'], 'notasecret'

    # gs = GoogleServiceAccount::Calendar.new(ENV["MY_SERVICE_ACCOUNT_EMAIL"])
    #
    # # gs = GoogleServiceAccount::Calendar.new(ENV["my_service_account_secondary_calendar_id"])
    # # google_events = gs.events(ENV["my_service_account_test_calendar_id"])
    # google_events = gs.events(ENV["my_service_account_secondary_calendar_id"])

    # assert gs.XX is something
    assert true
  end

end
