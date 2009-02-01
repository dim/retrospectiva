class AddUserIdColumnToSecureTokens < ActiveRecord::Migration
  def self.up
    add_column :secure_tokens, :user_id, :integer
    add_index :secure_tokens, :user_id, :name => 'i_stokens_user_id'
  end

  def self.down
    remove_index :secure_tokens, :name => 'i_stokens_user_id'
    remove_column :secure_tokens, :user_id
  end
end
