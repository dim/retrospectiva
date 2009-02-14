class UpgradeRepositoryTypesToModularStructure < ActiveRecord::Migration
  def self.up
    execute "UPDATE repositories SET type = 'Subversion' WHERE type = 'SubversionRepository'"
  end

  def self.down
    execute "UPDATE repositories SET type = 'SubversionRepository' WHERE type = 'Subversion'"
  end
end
