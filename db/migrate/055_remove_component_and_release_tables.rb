class RemoveComponentAndReleaseTables < ActiveRecord::Migration
  def self.up
    drop_table "components"
    drop_table "releases"
    remove_column :tickets, :release_id
    remove_column :tickets, :component_id
  end

  def self.down
    add_column :tickets, :release_id, :integer
    add_column  :tickets, :component_id, :integer
    add_index :tickets, :release_id
    add_index :tickets, :component_id

    create_table "components", :force => true do |t|
      t.column "name",       :string,  :limit => 50
      t.column "project_id", :integer
    end  
    add_index "components", ["project_id"], :name => "components_project_id_index"

    create_table "releases", :force => true do |t|
      t.column "name",       :string,  :limit => 25
      t.column "project_id", :integer
    end
    add_index "releases", ["project_id"], :name => "releases_project_id_index"
  end
end
