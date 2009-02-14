class AddTypeAttributeToRepositories < ActiveRecord::Migration
  def self.up
    add_column :repositories, :type, :string, :limit => 40
    add_index :repositories, [:type], :name => 'i_repositories_on_type'
    execute "UPDATE repositories SET type = 'SubversionRepository'"
  end

  def self.down
    remove_index :repositories, :name => 'i_repositories_on_type'
    remove_column :repositories, :type, :string
  end
end
