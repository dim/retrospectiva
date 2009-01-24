class AddLocaleColumnToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :locale, :string, :limit => 12
  end

  def self.down
    remove_column :projects, :locale
  end
end
