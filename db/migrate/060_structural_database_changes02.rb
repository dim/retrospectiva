class StructuralDatabaseChanges02 < ActiveRecord::Migration
  def self.try_removing_index(*args)
    remove_index(*args) rescue nil
  end
  
  def self.up
    try_removing_index "attachments", :name => "attachments_attachable_type_index"
    try_removing_index "changes", :name => "changes_changeset_id_index"
    try_removing_index "changes", :name => "index_changes_on_repository_id"
    try_removing_index "changesets", :name => "changesets_repository_id_index"
    try_removing_index "groups_projects", :name => "groups_projects_group_id_index"
    try_removing_index "groups_users", :name => "groups_users_group_id_index"
    try_removing_index "milestones", :name => "milestones_project_id_index"
    try_removing_index "milestones", :name => "index_milestones_on_rank"
    try_removing_index "priorities", :name => "index_priorities_on_rank"
    try_removing_index "projects", :name => "projects_short_name_index"
    try_removing_index "projects", :name => "projects_repository_id_index"
    try_removing_index "sessions", :name => "sessions_session_id_index"
    try_removing_index "status", :name => "index_status_on_rank"
    try_removing_index "taggings", :name => "taggings_tag_id_index"
    try_removing_index "tags", :name => "tags_name_index"
    try_removing_index "ticket_changes", :name => "ticket_changes_ticket_id_index"
    try_removing_index "ticket_properties", :name => "index_ticket_properties_on_rank"
    try_removing_index "ticket_properties", :name => "index_ticket_properties_on_ticket_property_type_id"
    try_removing_index "ticket_properties_tickets", :name => "uidx_ticket_properties_tickets", :unique => true
    try_removing_index "ticket_property_types", :name => "index_ticket_property_types_on_project_id"
    try_removing_index "ticket_reports", :name => "ticket_reports_project_id_index"
    try_removing_index "ticket_subscribers", :name => "index_ticket_subscribers_on_ticket_id"
    try_removing_index "ticket_subscribers", :name => "index_ticket_subscribers_on_user_id"
    try_removing_index "tickets", :name => "tickets_milestone_id_index"
    try_removing_index "tickets", :name => "tickets_priority_id_index"
    try_removing_index "tickets", :name => "tickets_status_id_index"
    try_removing_index "tickets", :name => "tickets_project_id_index"
    try_removing_index "tickets", :name => "tickets_assigned_user_id_index"
    try_removing_index "users", :name => "index_users_on_private_key"
    try_removing_index "users", :name => "index_users_on_login"
      
    add_index "attachments", ["attachable_type", "attachable_id"], :name => "i_att_on_type_and_id"
    add_index "changes", ["changeset_id"], :name => "i_changes_on_changeset"
    add_index "changes", ["repository_id"], :name => "i_changes_on_repository_id"
    add_index "changesets", ["repository_id"], :name => "i_cs_on_repository_id"
    add_index "groups_projects", ["group_id", "project_id"], :name => "i_gp_on_group_and_project"
    add_index "groups_users", ["group_id", "user_id"], :name => "i_gu_on_group_and_user"
    add_index "milestones", ["project_id"], :name => "i_mst_on_project_id"
    add_index "milestones", ["rank"], :name => "i_mst_on_rank"
    add_index "priorities", ["rank"], :name => "i_prt_on_rank"
    add_index "projects", ["short_name"], :name => "i_projects_on_short_name"
    add_index "projects", ["repository_id"], :name => "i_projects_on_repository_id"
    add_index "sessions", ["session_id"], :name => "i_sessions_on_session_id"
    add_index "status", ["rank"], :name => "i_status_on_rank"
    add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "i_taggings_on_references"
    add_index "tags", ["name"], :name => "i_tags_on_name"
    add_index "ticket_changes", ["ticket_id"], :name => "i_tchanges_on_ticket_id"
    add_index "ticket_properties", ["rank"], :name => "i_tprops_on_rank"
    add_index "ticket_properties", ["ticket_property_type_id"], :name => "i_t_props_on_tptype_id"
    add_index "ticket_properties_tickets", ["ticket_id", "ticket_property_id"], :name => "ui_tprops_on_tickets", :unique => true
    add_index "ticket_property_types", ["project_id"], :name => "i_tptypes_on_project_id"
    add_index "ticket_reports", ["project_id"], :name => "i_treports_on_project_id"
    add_index "ticket_subscribers", ["ticket_id"], :name => "i_tsubscribers_on_ticket_id"
    add_index "ticket_subscribers", ["user_id"], :name => "i_tsubscribers_on_user_id"
    add_index "tickets", ["milestone_id"], :name => "i_tickets_on_milestone_id"
    add_index "tickets", ["priority_id"], :name => "i_tickets_on_priority_id"
    add_index "tickets", ["status_id"], :name => "i_tickets_on_status_id"
    add_index "tickets", ["project_id"], :name => "i_tickets_on_project_id"
    add_index "tickets", ["assigned_user_id"], :name => "i_tickets_on_auser_id"
    add_index "users", ["private_key"], :name => "i_users_on_private_key"
    add_index "users", ["login"], :name => "i_users_on_login"

    begin
      remove_index :blog_comments, :name => "index_blog_comments_on_blog_post_id"
      remove_index :blog_posts, :name => "index_blog_posts_on_user_id"
      remove_index :blog_posts, :name => "index_blog_posts_on_project_id"
    rescue
    end

    begin
      add_index :blog_posts, :user_id, :name => "i_bposts_on_user_id"
      add_index :blog_posts, :project_id, :name => "i_bposts_on_project_id"
      add_index :blog_comments, :blog_post_id, :name => "i_bposts_on_bpost_id"   
    rescue
    end
    
    begin
      remove_index "wiki_pages", :name => "wiki_pages_title_index"
      remove_index "wiki_pages", :name => "wiki_pages_project_id_index"
      remove_index "wiki_versions", :name => "wiki_versions_project_id_index"
      remove_index "wiki_versions", :name => "wiki_versions_wiki_page_id_index"
      remove_index "wiki_versions", :name => "wiki_versions_user_id_index"
    rescue
    end
    
    begin
      add_index :wiki_pages, :title, :name => "i_wiki_pages_on_title"
      add_index :wiki_pages, :project_id, :name => "i_wiki_pages_on_project_id"
      add_index :wiki_versions, :project_id, :name => "i_wversions_on_project_id"
      add_index :wiki_versions, :wiki_page_id, :name => "i_wversions_on_wpage_id"
      add_index :wiki_versions, :user_id, :name => "i_wversions_on_user_id"
    rescue
    end    

    change_column :projects, :disabled_modules, :text    
    add_index "tickets", ["user_id"], :name => "i_tickets_on_user_id"
  end

  def self.down
    remove_index "attachments", :name => "i_att_on_type_and_id"
    remove_index "changes", :name => "i_changes_on_changeset"
    remove_index "changes", :name => "i_changes_on_repository_id"
    remove_index "changesets", :name => "i_cs_on_repository_id"
    remove_index "groups_projects", :name => "i_gp_on_group_and_project"
    remove_index "groups_users", :name => "i_gu_on_group_and_user"
    remove_index "milestones", :name => "i_mst_on_project_id"
    remove_index "milestones", :name => "i_mst_on_rank"
    remove_index "priorities", :name => "i_prt_on_rank"
    remove_index "projects", :name => "i_projects_on_short_name"
    remove_index "projects", :name => "i_projects_on_repository_id"
    remove_index "sessions", :name => "i_sessions_on_session_id"
    remove_index "status", :name => "i_status_on_rank"
    remove_index "taggings", :name => "i_taggings_on_references"
    remove_index "tags", :name => "i_tags_on_name"
    remove_index "ticket_changes", :name => "i_tchanges_on_ticket_id"
    remove_index "ticket_properties", :name => "i_tprops_on_rank"
    remove_index "ticket_properties", :name => "i_t_props_on_tptype_id"
    remove_index "ticket_properties_tickets", :name => "ui_tprops_on_tickets", :unique => true
    remove_index "ticket_property_types", :name => "i_tptypes_on_project_id"
    remove_index "ticket_reports", :name => "i_treports_on_project_id"
    remove_index "ticket_subscribers", :name => "i_tsubscribers_on_ticket_id"
    remove_index "ticket_subscribers", :name => "i_tsubscribers_on_user_id"
    remove_index "tickets", :name => "i_tickets_on_milestone_id"
    remove_index "tickets", :name => "i_tickets_on_priority_id"
    remove_index "tickets", :name => "i_tickets_on_status_id"
    remove_index "tickets", :name => "i_tickets_on_project_id"
    remove_index "tickets", :name => "i_tickets_on_auser_id"
    remove_index "users", :name => "i_users_on_private_key"
    remove_index "users", :name => "i_users_on_login"

    add_index "attachments", ["attachable_type", "attachable_id"], :name => "attachments_attachable_type_index"
    add_index "changes", ["changeset_id"], :name => "changes_changeset_id_index"
    add_index "changes", ["repository_id"], :name => "index_changes_on_repository_id"
    add_index "changesets", ["repository_id"], :name => "changesets_repository_id_index"
    add_index "groups_projects", ["group_id", "project_id"], :name => "groups_projects_group_id_index"
    add_index "groups_users", ["group_id", "user_id"], :name => "groups_users_group_id_index"
    add_index "milestones", ["project_id"], :name => "milestones_project_id_index"
    add_index "milestones", ["rank"], :name => "index_milestones_on_rank"
    add_index "priorities", ["rank"], :name => "index_priorities_on_rank"
    add_index "projects", ["short_name"], :name => "projects_short_name_index"
    add_index "projects", ["repository_id"], :name => "projects_repository_id_index"
    add_index "sessions", ["session_id"], :name => "sessions_session_id_index"
    add_index "status", ["rank"], :name => "index_status_on_rank"
    add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "taggings_tag_id_index"
    add_index "tags", ["name"], :name => "tags_name_index"
    add_index "ticket_changes", ["ticket_id"], :name => "ticket_changes_ticket_id_index"
    add_index "ticket_properties", ["rank"], :name => "index_ticket_properties_on_rank"
    add_index "ticket_properties", ["ticket_property_type_id"], :name => "index_ticket_properties_on_ticket_property_type_id"
    add_index "ticket_properties_tickets", ["ticket_id", "ticket_property_id"], :name => "uidx_ticket_properties_tickets", :unique => true
    add_index "ticket_property_types", ["project_id"], :name => "index_ticket_property_types_on_project_id"
    add_index "ticket_reports", ["project_id"], :name => "ticket_reports_project_id_index"
    add_index "ticket_subscribers", ["ticket_id"], :name => "index_ticket_subscribers_on_ticket_id"
    add_index "ticket_subscribers", ["user_id"], :name => "index_ticket_subscribers_on_user_id"
    add_index "tickets", ["milestone_id"], :name => "tickets_milestone_id_index"
    add_index "tickets", ["priority_id"], :name => "tickets_priority_id_index"
    add_index "tickets", ["status_id"], :name => "tickets_status_id_index"
    add_index "tickets", ["project_id"], :name => "tickets_project_id_index"
    add_index "tickets", ["assigned_user_id"], :name => "tickets_assigned_user_id_index"
    add_index "users", ["private_key"], :name => "index_users_on_private_key"
    add_index "users", ["login"], :name => "index_users_on_login"

    remove_index "tickets", :name => "i_tickets_on_user_id"
  end
end
