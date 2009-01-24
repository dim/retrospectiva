class AddPrivateKeyAttributeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :private_key, :string, :limit => 72
    add_index(:users, :private_key)

    User.find(:all).each do |user|
      user.update_attribute(:private_key, user.private_key)
    end
  end

  def self.down
    remove_column :users, :private_key
  end
end
