class UpdateChangesetsRevisionColumnToBeAString < ActiveRecord::Migration
  def self.up
    change_column :changesets, :revision, :string, :limit => 40
  end

  def self.down
    change_column :changesets, :revision, :integer
  end
end
