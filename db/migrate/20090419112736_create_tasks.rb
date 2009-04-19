class CreateTasks < ActiveRecord::Migration

  def self.up    
    create_table "tasks" do |t|
      t.string   "name", :limit => 60
      t.datetime "started_at",  :default => Time.utc(1970), :null => false
      t.datetime "finished_at", :default => Time.utc(1970), :null => false
      t.integer  "interval",    :default => 0,              :null => false
    end
    add_index :tasks, :name, :name => 'i_tasks_name'

    begin
      YAML.load_file(RAILS_ROOT + '/config/runtime/tasks.yml').each do |name, config|
        Retrospectiva::TaskManager::Task.create! :name => name, :interval => config[:interval].to_i
      end
    rescue
      Retrospectiva::TaskManager::Task.create! :name => 'sync_repositories', :interval => 600
      Retrospectiva::TaskManager::Task.create! :name => 'process_mails', :interval => 300
    end
  end

  def self.down
    remove_index :tasks, :name => 'i_tasks_name'
    drop_table "tasks"
  end

end
