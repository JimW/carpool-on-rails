require 'aws-sdk'

namespace :aws do

  desc "pushes source_path up to dest_path on AWS S3's ENV['AWS_S3_BUCKET']"
  task :push_to_s3, :source_path, :dest_path do |t, args|

    s3 = Aws::S3::Resource.new(region:'us-west-1')
    obj = s3.bucket(ENV['AWS_S3_BUCKET']).object(args[:dest_path])
    obj.upload_file(args[:source_path])

  end

end
