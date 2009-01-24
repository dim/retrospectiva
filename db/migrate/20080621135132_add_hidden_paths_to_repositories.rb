class AddHiddenPathsToRepositories < ActiveRecord::Migration
  def self.up
    add_column :repositories, :hidden_paths, :text
  end

  def self.down
    remove_column :repositories
  end
end
