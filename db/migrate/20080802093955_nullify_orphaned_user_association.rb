class NullifyOrphanedUserAssociation < ActiveRecord::Migration
  def self.up
    Retrospectiva::Misc.nullify_orphaned_associations Ticket, :user
    Retrospectiva::Misc.nullify_orphaned_associations Ticket, :assigned_user
    Retrospectiva::Misc.nullify_orphaned_associations TicketChange, :user
    Retrospectiva::Misc.nullify_orphaned_associations Changeset, :user
  end

  def self.down
  end
end
