# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090504172000) do

  create_table "attachments", :force => true do |t|
    t.string   "file_name"
    t.string   "content_type"
    t.string   "attachable_type", :limit => 30
    t.integer  "attachable_id"
    t.datetime "created_at"
    t.string   "type",            :limit => 20
    t.integer  "project_id"
  end

  add_index "attachments", ["attachable_type", "attachable_id"], :name => "i_att_on_type_and_id"
  add_index "attachments", ["project_id"], :name => "i_attachments_prj_id"
  add_index "attachments", ["type"], :name => "i_attachments_type"

  create_table "changes", :force => true do |t|
    t.integer "changeset_id"
    t.string  "revision",      :limit => 40, :default => "0", :null => false
    t.string  "name",          :limit => 2,  :default => "",  :null => false
    t.string  "path"
    t.string  "from_path"
    t.string  "from_revision", :limit => 40
    t.integer "repository_id"
  end

  add_index "changes", ["changeset_id"], :name => "i_changes_on_changeset"
  add_index "changes", ["from_path"], :name => "i_changes_on_from_path"
  add_index "changes", ["path"], :name => "i_changes_on_path"
  add_index "changes", ["repository_id"], :name => "i_changes_on_repository_id"

  create_table "changesets", :force => true do |t|
    t.string   "revision",      :limit => 40
    t.string   "author",        :limit => 50
    t.text     "log"
    t.datetime "created_at"
    t.integer  "repository_id",               :default => 0, :null => false
    t.integer  "user_id"
  end

  add_index "changesets", ["created_at"], :name => "i_cs_on_created_at"
  add_index "changesets", ["repository_id"], :name => "i_cs_on_repository_id"
  add_index "changesets", ["user_id"], :name => "i_cs_on_user_id"

  create_table "changesets_projects", :id => false, :force => true do |t|
    t.integer "changeset_id"
    t.integer "project_id"
  end

  add_index "changesets_projects", ["changeset_id"], :name => "i_cp_on_changeset"
  add_index "changesets_projects", ["project_id"], :name => "i_cp_on_project"

  create_table "configuration", :force => true do |t|
    t.text     "section_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string  "name",                   :limit => 40
    t.text    "permissions"
    t.boolean "access_to_all_projects",               :default => false, :null => false
  end

  create_table "groups_projects", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "project_id"
  end

  add_index "groups_projects", ["group_id", "project_id"], :name => "i_gp_on_group_and_project"

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "i_gu_on_group_and_user"

  create_table "milestones", :force => true do |t|
    t.string   "name",        :limit => 75
    t.text     "info"
    t.date     "due"
    t.datetime "created_at"
    t.integer  "project_id"
    t.date     "finished_on"
    t.integer  "rank",                      :default => 9999
    t.date     "started_on"
    t.datetime "updated_at"
  end

  add_index "milestones", ["project_id"], :name => "i_mst_on_project_id"
  add_index "milestones", ["rank"], :name => "i_mst_on_rank"
  add_index "milestones", ["updated_at"], :name => "i_mst_on_updated_at"

  create_table "priorities", :force => true do |t|
    t.string  "name",          :limit => 50
    t.boolean "default_value",               :default => false, :null => false
    t.integer "rank",                        :default => 9999
  end

  add_index "priorities", ["rank"], :name => "i_prt_on_rank"

  create_table "projects", :force => true do |t|
    t.string  "name"
    t.text    "info"
    t.string  "short_name"
    t.boolean "closed",                                 :default => false, :null => false
    t.integer "repository_id"
    t.string  "root_path",                              :default => ""
    t.text    "existing_tickets",   :limit => 16777215
    t.text    "existing_revisions", :limit => 16777215
    t.string  "locale",             :limit => 12
    t.text    "enabled_modules"
    t.boolean "central",                                :default => false, :null => false
  end

  add_index "projects", ["central"], :name => "i_projects_on_central"
  add_index "projects", ["repository_id"], :name => "i_projects_on_repository_id"
  add_index "projects", ["short_name"], :name => "i_projects_on_short_name"

  create_table "queued_mails", :force => true do |t|
    t.text     "object",            :limit => 16777215
    t.string   "mailer_class_name"
    t.datetime "created_at"
    t.datetime "delivered_at"
  end

  create_table "repositories", :force => true do |t|
    t.string "name"
    t.string "path"
    t.string "type",          :limit => 40
    t.text   "hidden_paths"
    t.string "sync_callback"
  end

  add_index "repositories", ["type"], :name => "i_repositories_on_type"

  create_table "secure_tokens", :force => true do |t|
    t.string   "value"
    t.datetime "expires_at"
    t.string   "type",       :limit => 20
    t.integer  "user_id"
  end

  add_index "secure_tokens", ["type"], :name => "i_stokens_type"
  add_index "secure_tokens", ["user_id"], :name => "i_stokens_user_id"
  add_index "secure_tokens", ["value"], :name => "i_stokens_value"

  create_table "statuses", :force => true do |t|
    t.string  "name",          :limit => 25
    t.boolean "default_value",               :default => false, :null => false
    t.integer "rank",                        :default => 9999
    t.integer "state_id",      :limit => 2
    t.integer "statement_id",  :limit => 2
  end

  add_index "statuses", ["rank"], :name => "i_status_on_rank"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", :limit => 30
    t.integer  "tagger_id"
    t.string   "tagger_type",   :limit => 30
    t.string   "context",       :limit => 30
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "i_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "i_taggings_on_references"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "i_tags_on_name"

  create_table "tasks", :force => true do |t|
    t.string   "name",        :limit => 60
    t.datetime "started_at",                :default => '1970-01-01 00:00:00', :null => false
    t.datetime "finished_at",               :default => '1970-01-01 00:00:00', :null => false
    t.integer  "interval",                  :default => 0,                     :null => false
  end

  add_index "tasks", ["name"], :name => "i_tasks_name"

  create_table "ticket_changes", :force => true do |t|
    t.integer  "ticket_id"
    t.string   "author",     :limit => 75
    t.text     "content"
    t.datetime "created_at"
    t.text     "updates"
    t.string   "email",      :limit => 75
    t.integer  "user_id"
  end

  add_index "ticket_changes", ["created_at"], :name => "i_tchanges_on_created_at"
  add_index "ticket_changes", ["ticket_id"], :name => "i_tchanges_on_ticket_id"

  create_table "ticket_properties", :force => true do |t|
    t.string  "name",                    :limit => 40
    t.integer "rank"
    t.integer "ticket_property_type_id"
  end

  add_index "ticket_properties", ["rank"], :name => "i_tprops_on_rank"
  add_index "ticket_properties", ["ticket_property_type_id"], :name => "i_t_props_on_tptype_id"

  create_table "ticket_properties_tickets", :id => false, :force => true do |t|
    t.integer "ticket_id"
    t.integer "ticket_property_id"
  end

  add_index "ticket_properties_tickets", ["ticket_id", "ticket_property_id"], :name => "ui_tprops_on_tickets", :unique => true

  create_table "ticket_property_types", :force => true do |t|
    t.string  "name",       :limit => 20
    t.integer "project_id"
    t.integer "rank",                     :default => 9999
  end

  add_index "ticket_property_types", ["project_id"], :name => "i_tptypes_on_project_id"
  add_index "ticket_property_types", ["rank"], :name => "i_prop_types_on_rank"

  create_table "ticket_reports", :force => true do |t|
    t.string  "name",           :limit => 100
    t.integer "rank",                          :default => 9999, :null => false
    t.text    "filter_options"
    t.integer "time_interval"
    t.integer "project_id"
  end

  add_index "ticket_reports", ["project_id"], :name => "i_treports_on_project_id"

  create_table "ticket_subscribers", :id => false, :force => true do |t|
    t.integer "ticket_id"
    t.integer "user_id"
  end

  add_index "ticket_subscribers", ["ticket_id"], :name => "i_tsubscribers_on_ticket_id"
  add_index "ticket_subscribers", ["user_id"], :name => "i_tsubscribers_on_user_id"

  create_table "tickets", :force => true do |t|
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
  end

  add_index "tickets", ["assigned_user_id"], :name => "i_tickets_on_auser_id"
  add_index "tickets", ["milestone_id"], :name => "i_tickets_on_milestone_id"
  add_index "tickets", ["priority_id"], :name => "i_tickets_on_priority_id"
  add_index "tickets", ["project_id"], :name => "i_tickets_on_project_id"
  add_index "tickets", ["status_id"], :name => "i_tickets_on_status_id"
  add_index "tickets", ["user_id"], :name => "i_tickets_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "username",        :limit => 80
    t.string   "password",        :limit => 40
    t.datetime "created_at"
    t.boolean  "admin",                         :default => false,    :null => false
    t.string   "name",            :limit => 80
    t.string   "email",           :limit => 80
    t.string   "salt",            :limit => 8
    t.boolean  "active",                        :default => true,     :null => false
    t.string   "activation_code"
    t.string   "private_key",     :limit => 72
    t.string   "scm_name",        :limit => 80
    t.string   "time_zone",       :limit => 30, :default => "London", :null => false
  end

  add_index "users", ["private_key"], :name => "i_users_on_private_key"
  add_index "users", ["scm_name"], :name => "i_users_on_scm_name"
  add_index "users", ["username"], :name => "i_users_on_login"

end
