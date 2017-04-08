class AddActiveToCarpoolUsers < ActiveRecord::Migration
  def change
    add_column :carpool_users, :is_active, :boolean, :default => true
  end
end
