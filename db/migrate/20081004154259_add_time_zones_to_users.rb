class AddTimeZonesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :time_zone, :string, :limit => 30, :null => false, :default => 'London'
  end

  def self.down
    remove_column :users, :time_zone
  end
end
