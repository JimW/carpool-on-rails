
namespace :db do

  desc "!! Drops, recreates, and seeds database. Careful...!!"
  task :rebuild_dev do

    if Rails.env.development?
      # print "WARNING: about to Drop, recreate, and seed database as well as blow away all google calendars owned by service account.  Continue? (y/n): "
      #   option = STDIN.gets.strip
      #   case option[0]
      #     when 'N','n'
      #       abort("****** db:rebuild_dev Task ABORTED ******")
      #     when 'Y','y'
            Rake::Task["db:drop:all"].invoke
            Rake::Task["db:create"].invoke
            Rake::Task["db:migrate"].invoke
            Rake::Task["aws:plant_seeds"].invoke
            Rake::Task["db:seed"].invoke
            Rake::Task["gs:delete_all_calendars"].invoke
        # end
    else
      p "rebuild_dev is only for DEV"
    end
  end
  # task :rebuild_dev => ["db:drop:all", "db:create", "db:migrate", "db:seed", "gs:delete_all_calendars"]

# TODO: would like to force the env to TEST, not sure a good way..
# This task is necessary because the Test DB can get itself tied up in knots 
  # task :rebuild_test do
  #   if Rails.env.test?
  #       Rake::Task["db:drop:all"].invoke
  #       Rake::Task["db:create"].invoke
  #       Rake::Task["db:migrate"].invoke
  #       # Rake::Task["gs:delete_all_calendars"].invoke
  #   else
  #     p "rebuild_test is only for TEST"
  #   end
  # end

end
