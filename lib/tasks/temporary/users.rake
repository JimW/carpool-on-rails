# lib/tasks/temporary/users.rake
namespace :users do

  desc "Set all users as Active for every Carpool"
  task :set_all_active_for_all_carpools => :environment do

    puts "Going to update #{User.all.count} users across #{Carpool.all.count} carpools (#{User.all.count * Carpool.all.count} records)"

    ActiveRecord::Base.transaction do
      User.all.each do |user|
        Carpool.all.each do |carpool|
          user_detail = user.carpool_users.where(carpool_id: carpool.id).first
          user_detail.is_active = true
          print "."
        end
      end
    end
    puts " All done now!"
  end


end