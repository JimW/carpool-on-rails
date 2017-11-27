# lib/tasks/temporary/users.rake
namespace :users do

  desc "Set all users as Active for every Carpool"
  task :set_all_active_for_all_carpools => :environment do

    puts "Going to update #{User.all.count} users across #{Carpool.all.count} carpools (#{User.all.count * Carpool.all.count} records)"

    ApplicationRecord.transaction do
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

 desc "Add user if not already"
  task :add_all_to, [:carpool_title_short] => :environment do |t, args|
    p args[:carpool_title_short] 

    mycarpool = Carpool.where(:title_short => args[:carpool_title_short]).first 
    p args['carpool_title_short'] + " does NOT exist !!! " if mycarpool.nil?
    ApplicationRecord.transaction do
      User.all.each do |user|
        if !user.carpools.exists?(mycarpool.id)
          if (user.can_drive)
            mycarpool.drivers << user
          else
            mycarpool.passengers << user
          end
          p "ADDED " + user.full_name + " to " + mycarpool.title_short
        end 
      end
    end
    puts " All done now!"
  end

end