class CleanUpAndRemoveRedundantColumns < ActiveRecord::Migration
  def self.up
    if columns('priorities').map(&:name).include?('default')
      remove_column :priorities, :default
    end

    col_root_path = columns('projects').find {|c| c.name == 'root_path' } 
    if col_root_path and col_root_path.limit > 255
      change_column :projects, :root_path, :string, :limit => 255
    end

    changes_indexes = indexes('changes').map(&:name)
    unless changes_indexes.include?('i_changes_on_from_path')
      add_index "changes", ["from_path"], :name => "i_changes_on_from_path"
    end
    unless changes_indexes.include?('i_changes_on_path')
      add_index "changes", ["path"], :name => "i_changes_on_path"
    end
    
    remove_column 'ticket_changes', "approved"
    remove_column 'ticket_changes', "spam"
    remove_column 'tickets', "approved"
    remove_column 'tickets', "spam"
    
    change_column :projects, :closed, :boolean, :null => false
  end

  def self.down    
    change_column :projects, :closed, :boolean, :null => true

    add_column 'ticket_changes', "approved", :boolean, :default => false, :null => false
    add_column 'ticket_changes', "spam", :boolean, :default => false, :null => false
    add_column 'tickets', "approved", :boolean, :default => false, :null => false
    add_column 'tickets', "spam", :boolean, :default => false, :null => false
    
    remove_index :changes, :name => "i_changes_on_from_path"
    remove_index :changes, :name => "i_changes_on_path"
    add_index "changes", ["path"], :name => "path"
  end
end
