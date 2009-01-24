class DropFactoryHashCaches < ActiveRecord::Migration
  def self.up
    drop_table 'factory_hashcashes'
  end

  def self.down
    create_table "factory_hashcashes", :force => true do |t|
      t.string   "key"
      t.string   "salt"
      t.string   "result"
      t.datetime "created_at"
    end
  end
end
