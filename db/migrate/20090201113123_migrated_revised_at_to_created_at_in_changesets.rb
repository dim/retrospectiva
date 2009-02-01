class MigratedRevisedAtToCreatedAtInChangesets < ActiveRecord::Migration
  def self.up
    execute "UPDATE changesets SET created_at = revised_at"
    remove_column :changesets, :revised_at  
    add_index "changesets", ["created_at"], :name => "i_cs_on_created_at"
  end

  def self.down
    add_column :changesets, :revised_at  
    remove_index "changesets", :name => "i_cs_on_created_at"
    execute "UPDATE changesets SET revised_at = created_at"
  end
end
