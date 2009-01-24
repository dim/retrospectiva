class StringifyFromRevisionsInChanges < ActiveRecord::Migration
  def self.up
    change_column :changes, :from_revision, :string, :limit => 40
  end

  def self.down
    change_column :changes, :from_revision, :integer
  end
end
