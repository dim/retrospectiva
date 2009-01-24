class RemoveDisabledModulesColumnFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :disabled_modules
  end

  def self.down
    add_column :projects, :disabled_modules, :text
  end
end
