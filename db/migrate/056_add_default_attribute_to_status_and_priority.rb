class AddDefaultAttributeToStatusAndPriority < ActiveRecord::Migration
  def self.up
    add_column :priorities, :default_value, :boolean, :null => false, :default => false
    add_column :status, :default_value, :boolean, :null => false, :default => false
    
    execute "UPDATE status SET default_value = #{quoted_true} WHERE name = 'Open'"
    execute "UPDATE priorities SET default_value = #{quoted_true} WHERE name = 'Normal'"
  end

  def self.down
    remove_column :priorities, :default_value
    remove_column :status, :default_value
  end
end
