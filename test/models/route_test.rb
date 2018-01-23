require 'test_helper'

class RouteTest < ActiveSupport::TestCase

  def setup
    setup_5_routes_on_main_carpool
    @route = Route.new(
      starts_at: 'Wed Jan 24 2018 08:20:00 GMT-0800 (Pacific Standard Time)', 
      ends_at: 'Wed Jan 24 2018 08:40:00 GMT-0800'
      )
  end

  test 'valid route' do
    assert @route.valid?
  end

  test 'validates starts_at' do
    @route.starts_at = ''
    refute @route.valid?, 'route is valid without a starts_at'
    assert_not_nil @route.errors[:starts_at], 'no validation error for starts_at present'
  end

  test 'validates ends_at' do
    @route.ends_at = ''
    refute @route.valid?, 'route is valid without a ends_at'
    assert_not_nil @route.errors[:ends_at], 'no validation error for ends_at present'
  end

  # params:
  # {"starts_at"=>"Wed Jan 24 2018 08:20:00 GMT-0800 (Pacific Standard Time)", 
  # "ends_at"=>"Wed Jan 24 2018 08:40:00 GMT-0800", 
  # "location_ids"=>[""], 
  # "passenger_ids"=>[""], 
  # "driver_ids"=>[""]}

  test 'scopes' do
    assert_includes Route.of_category(:special), routes(:special1)
    assert_includes Route.is_special, routes(:special1)
    assert_includes Route.is_template, routes(:template1)
    assert_not_includes Route.is_template, routes(:modified_instance1)
    assert_includes Route.is_instance, routes(:instance1)
    assert_includes Route.is_modified_instance, routes(:modified_instance1)
  end

  test "special as_fullcalendar_event" do
    # https://fullcalendar.io/docs/event_data/Event_Object/

    result = @special1.as_fullcalendar_event
    referenceResult = {
      :id=> @special1.event.id,
      :title=>" DRIVER ? : LOCATION ?",
      :description=>"PASSENGERS ?",
      :start=>"2018-01-18T00:20:00-08:00",
      :end=>"2018-01-18T00:40:00-08:00",
      :allDay=>false,
      :recurring=>false,
      :category=>"special",
      :has_children=>false,
      :route_id=> @special1.id,
      :child_id=>"",
      :parent_template_id=>""
    }
    assert result == referenceResult
  end

  test "template as_fullcalendar_event" do
    result = @template1.as_fullcalendar_event
    referenceResult = {
      :id=>@template1.event.id,
      :title=>" DRIVER ? : LOCATION ?",
      :description=>"PASSENGERS ?",
      :start=>"2018-01-17T00:00:00-08:00",
      :end=>"2018-01-17T01:00:00-08:00",
      :allDay=>true,
      :recurring=>false,
      :category=>"template",
      :has_children=>true,
      :route_id=> @template1.id,
      :child_id=>@template1.scheduled_instances.first.event.id,
      :parent_template_id=>""
    }
    assert result == referenceResult
  end

  test "instance as_fullcalendar_event" do
    result = @instance1.as_fullcalendar_event
    referenceResult = {
      :id=> @instance1.event.id,
      :title=>" DRIVER ? : LOCATION ?",
      :description=>"PASSENGERS ?",
      :start=>"2018-01-17T00:00:00-08:00",
      :end=>"2018-01-17T01:00:00-08:00",
      :allDay=>false,
      :recurring=>false,
      :category=>"instance",
      :has_children=>false,
      :route_id=> @instance1.id,
      :child_id=>"",
      :parent_template_id=> @instance1.instance_parent.event.id
    }
    assert result == referenceResult
  end

# Test:
# Driver(s):
# Jim Aa (555) 555-1111
# _________ 4 Passengers: _________
# Lucas LastName (555) 555 2222
# Bodhi LastName (555)  555-3333
end
