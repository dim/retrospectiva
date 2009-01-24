class RemoveSvnSpecificColumnsFromRepositories < ActiveRecord::Migration
  def self.up
    remove_column :repositories, :use_svnsync
    remove_column :repositories, :svnsync_args
  end

  def self.down
    add_column :repositories, "use_svnsync", :boolean,  :default => false, :null => false
    add_column :repositories, "svnsync_args", :string, :limit => 80
  end
end
