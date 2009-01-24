class MoveRetroConfigurationIntoDatabase < ActiveRecord::Migration
  def self.up
    create_table 'configuration' do |t|
      t.text :section_hash
      t.timestamps
    end
  end

  def self.down
    drop_table 'configuration'
  end
end
