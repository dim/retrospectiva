class UpdateDefaultStatusStatements < ActiveRecord::Migration
  def self.up
    execute "UPDATE statuses SET statement_id = 1 WHERE name = 'Fixed'"
    execute "UPDATE statuses SET statement_id = 3 WHERE name IN ('Duplicate', 'Invalid', 'WorksForMe', 'WontFix')"
  end

  def self.down
  end
end
