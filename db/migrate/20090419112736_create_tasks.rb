class CreateTasks < ActiveRecord::Migration

  def self.up    
    create_table "tasks" do |t|
      t.string   "name", :limit => 60
      t.datetime "started_at",  :default => Time.utc(1970), :null => false
      t.datetime "finished_at", :default => Time.utc(1970), :null => false
      t.integer  "interval",    :default => 0,              :null => false
    end
    add_index :tasks, :name, :name => 'i_tasks_name'

    sql = lambda {|name, interval| "INSERT INTO tasks (#{quote_column_name('name')}, #{quote_column_name('interval')}) VALUES (#{quote(name.to_s)}, #{interval.to_i})" }

    begin
      YAML.load_file(RAILS_ROOT + '/config/runtime/tasks.yml').each do |name, config|
        next if name.blank?
        insert_sql sql.call(name, config[:interval]) 
      end
    rescue
      insert_sql sql.call('sync_repositories', 600) 
      insert_sql sql.call('process_mails', 300) 
    end
  end

  def self.down
    remove_index :tasks, :name => 'i_tasks_name'
    drop_table "tasks"
  end

end
