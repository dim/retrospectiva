class UpgradeRepositoryTypesToModularStructure < ActiveRecord::Migration
  def self.up
    Repository.
      update_all("type = 'Subversion'", "type = 'SubversionRepository'")
  end

  def self.down
    Repository.
      update_all("type = 'SubversionRepository'", "type = 'Subversion'")
  end
end
