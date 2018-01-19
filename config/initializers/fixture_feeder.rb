class ActiveRecord::Base
  def feed_to_fixture
    fixture_file = "#{Rails.root}/test/fixtures/#{self.class.table_name}.yml" 
    attributes_without_time = attributes.inject({}) { |h, (k, v)| 
        h[k] = v.is_a?(Time) ? v.to_s(:rfc8601) : v 
        h 
      } 

    File.open(fixture_file, "a+") do |f|
      f.puts( { "#{self.class.table_name.singularize}_#{id}" => attributes_without_time }.to_yaml.sub!(/---\s?/, "\n"))
    end
  end
end

# http://api.rubyonrails.org/classes/ActiveSupport/TimeWithZone.html
