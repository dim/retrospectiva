class AddCentralAttributeToProjects < ActiveRecord::Migration
  
  def self.up    
    add_column :projects, :central, :boolean, :default => false, :null => false
    add_index :projects, :central, :name => "i_projects_on_central"

    projects = select_all "SELECT id FROM projects WHERE closed = #{quoted_false}"
    if projects.size == 1
      execute "UPDATE projects SET central = #{quoted_true} WHERE id = #{projects.first['id']}"
    end
  end

  def self.down
    remove_index :projects, :name => "i_projects_on_central"
    remove_column :projects, :central  
  end
  
end
