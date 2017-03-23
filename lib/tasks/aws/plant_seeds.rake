require 'aws-sdk'

namespace :aws do

# Do this only

  desc "Converts data_seed.yml containing seed data into data_seed.json and pushes up to AWS S3."
  task :plant_seeds, [:seed_dir, :seed_file_name] => [:environment] do |t, args|
    args.with_defaults(
      :seed_source_dir => 'heroku_staging',
      :seed_file_name => 'seed_data'
    )

    if ENV['AWS_S3_SEED_DIR_PATH'].nil?
      p "ENV['AWS_S3_SEED_DIR_PATH'] has not been set for " + Rails.env + " !!!  Not Pushing seed data to AWS S3"
      next # acts like return
    end

    debug = false;

    seed_root = 'db/seeds/development/'
    seed_source = seed_root + args[:seed_source_dir] + '/'

    seed_source_file =  args[:seed_file_name] + '.yml'
    seed_dest_file =  args[:seed_file_name] + '.json'

    local_yaml_path = seed_source + seed_source_file
    local_json_path = seed_source + seed_dest_file

    remote_json_path = ENV['AWS_S3_SEED_DIR_PATH'] + "/" + seed_dest_file

    seed_data_yaml = YAML.load_file(local_yaml_path)
    data_hash = Hash.new
    # data_hash['orgs'] = seed_data_yaml
    data_hash = seed_data_yaml

    json_data = data_hash.to_json
    json_data = JSON.pretty_generate(data_hash) if debug

    File.open(local_json_path, 'w') {|f| f.write json_data } #Store

    # File.open(local_json_path, 'w') {|f| f.write data_hash.to_json } #Store

    Rake::Task["aws:push_to_s3"].invoke(local_json_path, remote_json_path)

    File.delete(local_json_path) if !debug
    
    p "Local file: " + local_yaml_path + " converted and pushed to: " + remote_json_path + " on AWS S3"

  end

end
