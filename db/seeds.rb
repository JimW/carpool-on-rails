# db/seeds.rb
require 'yaml'

# Processes each chunk of users associated with a particular Role
def seed_users(org, cp, member_roles_hash)
  role_name = member_roles_hash['role']
  users = member_roles_hash['users']

  p "Seeding '" + role_name.to_s + "' Users for " + cp.title_short

  users.each { |usr|
    user = User.new(usr) # do this way because we are passing password that gets processed

    if (role_name == 'admin')
      user.add_role :admin
    elsif (role_name != 'peon')
      user.add_role(role_name, cp)
    end

    # user.lobby = org.lobby
    user.current_carpool = cp
    user.save!
    # user.current_organization = org TBD !!!

    org.users << user

    if (user.can_drive)
      cp.drivers << user
      org.lobby.drivers << user
    else
      cp.passengers << user
      org.lobby.passengers << user
    end
  }
end

# Pull that seed data from json, either on S3 or local (if dev)
def get_seed_data_from_local_yml
  seed_file = 'seed_data.yml'
  seed_path = 'db/seeds/development/' + seed_file

  p "Getting seed data from LOCAL within " + seed_path

  raw_hash = YAML.load_file(seed_path)
  return raw_hash
end

# Retrieves json data that was previously created and pushed up via rake aws:plant_seeds
#  (using seeds/development/heroku_staging_or_production/seed_data.yml)
def get_seed_data_from_s3_json
  seed_dest_file = 'seed_data.json'
  remote_json_path = ENV['AWS_S3_SEED_DIR_PATH'] + "/" + seed_dest_file

  p "Seeding data from AWS S3 bucket: "+ ENV['AWS_S3_BUCKET'] + "/" + remote_json_path

  s3 = Aws::S3::Client.new
  resp = s3.get_object(bucket:ENV['AWS_S3_BUCKET'], key: remote_json_path)
  jsonValue=  resp.body.read
  raw_hash = JSON.parse(jsonValue)
  return raw_hash
end

# Should only be playing with one org for now !!! Later maybe fix this up so multiple seperate orgs can be defined in seperate yamls
# For now, stick to a single org
@seed_data = ENV['AWS_S3_SEED_DIR_PATH'].nil? ? get_seed_data_from_local_yml : get_seed_data_from_s3_json

orgs_hash = @seed_data['orgs']
orgs_hash.each { |org_seed_hash|

  p "Seeding Data for Org: " + org_seed_hash['title_short']

  org = Organization.find_or_create_by!(org_seed_hash.slice('title_short', 'title', 'description' ))

  carpools = org_seed_hash['carpools']
  carpools.each { |carpool_seed_hash|

    p "Seeding Carpool: " + carpool_seed_hash['title_short']

    carpool = org.carpools.find_or_create_by!(carpool_seed_hash.slice('title_short', 'title'))

    locations = carpool_seed_hash['locations']
    locations.each { |location_seed_hash|
        loc = Location.find_or_create_by(location_seed_hash)
        loc.carpools << carpool
        loc.save
    } if locations

    member_roles = carpool_seed_hash['member_roles']
    member_roles.each { |roles_seed_hash|
      # p "roles_seed_hash = " + roles_seed_hash.to_s
      seed_users(org, carpool, roles_seed_hash)
    } if member_roles

  }
}
