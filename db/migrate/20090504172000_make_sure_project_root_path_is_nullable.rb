class MakeSureProjectRootPathIsNullable < ActiveRecord::Migration
  def self.up
    change_column :projects, :root_path, :string, :limit => 255
  end

  def self.down
  end
end
