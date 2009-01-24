class AddTypeAttributeToRepositories < ActiveRecord::Migration
  def self.up
    add_column :repositories, :type, :string, :limit => 40
    add_index :repositories, [:type], :name => 'i_repositories_on_type'
    Repository.find(:all).each do |repos|
      repos.update_attribute(:type, 'SubversionRepository')
    end
  end

  def self.down
    remove_index :repositories, :name => 'i_repositories_on_type'
    remove_column :repositories, :type, :string
  end
end
