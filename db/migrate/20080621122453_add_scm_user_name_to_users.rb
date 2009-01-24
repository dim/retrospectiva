class AddScmUserNameToUsers < ActiveRecord::Migration
  def self.up
    unless columns('users').map(&:name).include?('scm_name')
      add_column :users, :scm_name, :string, :limit => 40
    end
    unless indexes('users').map(&:name).include?('i_users_on_scm_name')
      add_index "users", ["scm_name"], :name => "i_users_on_scm_name"
    end
  end

  def self.down
    remove_index "users", :name => "i_users_on_scm_name"
    remove_column :users, :scm_name
  end
end
