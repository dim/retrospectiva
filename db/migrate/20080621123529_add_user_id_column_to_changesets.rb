class AddUserIdColumnToChangesets < ActiveRecord::Migration
  def self.up
    add_column :changesets, :user_id, :integer
    add_index "changesets", ["user_id"], :name => "i_cs_on_user_id"
  end

  def self.down
    remove_index "changesets", :name => "i_cs_on_user_id"
    remove_column :changesets, :user_id
  end
end
