class AddProjectIdToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :project_id, :integer
    add_index :attachments, :project_id, :name => 'i_attachments_prj_id'
  end

  def self.down
    remove_column :attachments, :project_id
  end
end
