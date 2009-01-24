class AddRankToTicketPropertyTypes < ActiveRecord::Migration
  def self.up
    add_column :ticket_property_types, :rank, :integer, :default => 9999
    add_index :ticket_property_types, :rank, :name => "i_prop_types_on_rank"
  end

  def self.down
    remove_index :ticket_property_types, :name => "i_prop_types_on_rank"
    remove_column :ticket_property_types, :rank
  end
end
