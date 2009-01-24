class MigrateTextColumnsForMySqlCompatibility < ActiveRecord::Migration
  def self.up
    change_column :changesets, :log, :text
    change_column :configuration, :section_hash, :text
    change_column :groups, :permissions, :text
    change_column :milestones, :info, :text
    change_column :projects, :info, :text
    change_column :projects, :existing_tickets, :text, :limit => (16.megabytes - 1)
    change_column :projects, :existing_revisions, :text, :limit => (16.megabytes - 1)
    change_column :projects, :enabled_modules, :text
    change_column :queued_mails, :object, :text, :limit => (16.megabytes - 1)        
    change_column :repositories, :hidden_paths, :text
    change_column :ticket_changes, :content, :text
    change_column :ticket_changes, :updates, :text
    change_column :ticket_reports, :filter_options, :text
    change_column :tickets, :content, :text
  end

  def self.down
    change_column :changesets, :log, :text
    change_column :configuration, :section_hash, :text
    change_column :groups, :permissions, :text
    change_column :milestones, :info, :text
    change_column :projects, :info, :text
    change_column :projects, :existing_tickets, :text
    change_column :projects, :existing_revisions, :text
    change_column :projects, :enabled_modules, :text
    change_column :queued_mails, :object, :text        
    change_column :repositories, :hidden_paths, :text
    change_column :ticket_changes, :content, :text
    change_column :ticket_changes, :updates, :text
    change_column :ticket_reports, :filter_options, :text
    change_column :tickets, :content, :text
  end
end
