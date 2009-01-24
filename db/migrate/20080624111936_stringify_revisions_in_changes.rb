class StringifyRevisionsInChanges < ActiveRecord::Migration
  def self.up
    change_column :changes, :revision, :string, :limit => 40
  end

  def self.down
    change_column :changes, :revision, :integer
  end
end
