require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  
  def setup
    @org = organizations(:dtech)
  end

  test "associations" do
    assert @org.carpools.count == 2
  end

end