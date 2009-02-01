class RenameTansToSecureTokens < ActiveRecord::Migration
  def self.up
    rename_table :tans, :secure_tokens
    add_column :secure_tokens, :type, :string, :limit => 20
    add_index :secure_tokens, :type, :name => 'i_stokens_type'
    add_index :secure_tokens, :value, :name => 'i_stokens_value'
    
    execute "UPDATE secure_tokens SET type = 'SecureToken' WHERE type IS NULL"    
  end

  def self.down
    remove_index :secure_tokens, :name => 'i_stokens_type'
    remove_index :secure_tokens, :name => 'i_stokens_value'
    remove_column :secure_tokens, :type
    rename_table :secure_tokens, :tans
  end
end
