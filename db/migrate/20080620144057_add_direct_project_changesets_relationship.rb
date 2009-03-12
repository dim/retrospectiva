class AddDirectProjectChangesetsRelationship < ActiveRecord::Migration
  def self.up
    create_table "changesets_projects", :id => false, :force => true do |t|
      t.integer "changeset_id"
      t.integer "project_id"
    end
    add_index "changesets_projects", 'project_id', :name => 'i_cp_on_project'
    add_index "changesets_projects", 'changeset_id', :name => 'i_cp_on_changeset'
  end

  def self.down
    remove_index "changesets_projects", :name => 'i_cp_on_project'
    remove_index "changesets_projects", :name => 'i_cp_on_changeset'
    drop_table 'changesets_projects'
  end
end
