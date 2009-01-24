class DropActiveRecordSessionsTable < ActiveRecord::Migration
  def self.up
    remove_index "sessions", :name => "i_sessions_on_session_id"
    drop_table 'sessions'
  end

  def self.down
    create_table "sessions", :force => true do |t|
      t.string   "session_id"
      t.text     "data"
      t.datetime "updated_at"
    end
  
    add_index "sessions", ["session_id"], :name => "i_sessions_on_session_id"
  end
end
