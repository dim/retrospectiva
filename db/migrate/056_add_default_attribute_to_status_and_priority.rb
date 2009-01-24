class AddDefaultAttributeToStatusAndPriority < ActiveRecord::Migration
  def self.up
    add_column :priorities, :default_value, :boolean, :null => false, :default => false
    add_column :status, :default_value, :boolean, :null => false, :default => false
    
    Status.set_table_name('status')
    Status.update_all(['default_value = ?', true], ['name = ?', 'Open'])
    Priority.update_all(['default_value = ?', true], ['name = ?', 'Normal'])    
  end

  def self.down
    remove_column :priorities, :default_value
    remove_column :status, :default_value
  end
end
