class CreateBaseTables < ActiveRecord::Migration
  def self.up
    versions = ActiveRecord::Migrator.get_all_versions
    return if versions.any? and versions.first.to_i == 48
    
    create_table "attachments" do |t|
      t.string   "original_filename"
      t.string   "content_type"
      t.string   "attachable_type", :limit => 30
      t.integer  "attachable_id"
    end
  
    create_table "changes" do |t|    
      t.integer "changeset_id"
      t.string  "revision",      :limit => 40, :default => "0", :null => false
      t.string  "name",          :limit => 2,  :default => "",  :null => false
      t.string  "path"
      t.string  "from_path"
      t.string  "from_revision", :limit => 40
      t.integer "repository_id"
    end
  
    create_table "changesets" do |t|
      t.string   "revision",      :limit => 40
      t.string   "author",        :limit => 50
      t.text     "log"
      t.datetime "created_at"
      t.datetime "revised_at"
      t.integer  "repository_id",               :default => 0, :null => false
    end

    create_table "factory_hashcashes" do |t|
    end
    
    create_table "groups" do |t|
      t.string  "name",                   :limit => 40
      t.text    "permissions"
      t.boolean "access_to_all_projects",               :default => false, :null => false
    end
  
    create_table "groups_projects", :id => false do |t|
      t.integer "group_id"
      t.integer "project_id"
    end
  
    create_table "groups_users", :id => false do |t|
      t.integer "group_id"
      t.integer "user_id"
    end
  
    create_table "milestones" do |t|
      t.string   "name",        :limit => 75
      t.text     "info"
      t.date     "due"
      t.datetime "created_at"
      t.integer  "project_id"
      t.date     "finished_on"
    end
  
    create_table "priorities" do |t|
      t.string  "name",          :limit => 50
      t.integer "position",                        :default => 9999
    end
    
    create_table "projects" do |t|
      t.string  "name"
      t.text    "info"
      t.string  "short_name"
      t.boolean "closed",                                 :default => false, :null => false
      t.integer "repository_id"
      t.string  "root_path",                              :default => ""
      t.text    "disabled_modules"
    end
  
    create_table "repositories" do |t|
      t.string "name"
      t.string "path"
    end
    
    create_table "sessions", :id => false do |t|
      t.string "session_id"
    end
  
    create_table "status" do |t|
      t.string  "name",          :limit => 25
    end

    create_table "tans", :force => true do |t|
      t.string   "value"
      t.datetime "expires_at"
    end
  
    create_table "taggings" do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type", :limit => 30
    end
  
    create_table "tags" do |t|
      t.string "name"
    end
  
    create_table "ticket_changes" do |t|
      t.integer  "ticket_id"
      t.string   "author",     :limit => 75
      t.text     "comment"
      t.datetime "created_at"
      t.text     "changes"
      t.string   "email",      :limit => 75
      t.integer  "user_id"
      t.boolean "approved"
      t.boolean "spam"
    end
    
    create_table "ticket_reports" do |t|
      t.string  "name",           :limit => 100
      t.integer "position",       :default => 9999, :null => false
      t.text    "filter_options"
      t.integer "time_interval"
      t.integer "project_id"
    end
    
    create_table "tickets" do |t|
      t.integer  "milestone_id"
      t.integer  "priority_id"
      t.integer  "status_id"
      t.string   "author",           :limit => 75
      t.string   "summary"
      t.text     "content"
      t.string   "author_host",      :limit => 100
      t.datetime "created_at"
      t.integer  "project_id"
      t.integer  "assigned_user_id"
      t.string   "email",            :limit => 75
      t.datetime "updated_at"
      t.integer  "user_id"
      t.integer  "release_id"
      t.integer  "component_id"
      t.boolean "approved"
      t.boolean "spam"
    end
  
    create_table "users" do |t|
      t.string   "login",        :limit => 80
      t.string   "password",        :limit => 40
      t.datetime "created_at"
      t.boolean  "admin",                         :default => false,    :null => false
      t.string   "name",            :limit => 80
      t.string   "email",           :limit => 80
      t.string   "salt",            :limit => 8
      t.boolean  "active",                        :default => true,     :null => false
      t.string   "activation_code"
    end

    create_table "components" do |t|
      t.column "name",       :string,  :limit => 50
      t.column "project_id", :integer
    end  

    create_table "releases" do |t|
      t.column "name",       :string,  :limit => 25
      t.column "project_id", :integer
    end
  end
  
  def self.down
    drop_table "attachments"
    drop_table "changes"
    drop_table "changesets"
    drop_table "factory_hashcashes"
    drop_table "groups"
    drop_table "groups_projects"
    drop_table "groups_users"
    drop_table "milestones"
    drop_table "priorities"
    drop_table "projects"
    drop_table "repositories"
    drop_table "sessions"
    drop_table "status"
    drop_table "tans"
    drop_table "taggings"
    drop_table "tags"
    drop_table "ticket_changes"
    drop_table "ticket_reports"
    drop_table "tickets"
    drop_table "users"
    drop_table "components"
    drop_table "releases"
  end
end
