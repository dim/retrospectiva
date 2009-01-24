class MigrateAllBigIntColumnsToSimpleIntegers < ActiveRecord::Migration
  def self.up
    change_column :changesets_projects, :changeset_id, :integer
    change_column :changesets_projects, :project_id, :integer
    change_column :changesets, :user_id, :integer
  end

  def self.down
  end
end
