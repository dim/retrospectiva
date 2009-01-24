class CreateTicketProperties < ActiveRecord::Migration
  class ::Release < ActiveRecord::Base
    belongs_to :project
  end
  
  class ::Component < ActiveRecord::Base
    belongs_to :project
  end

  def self.up
    create_table :ticket_property_types do |t|
      t.column :name,       :string, :limit => 20
      t.column :project_id, :integer
    end
    add_index :ticket_property_types, :project_id

    create_table :ticket_properties do |t|
      t.column :name,       :string, :limit => 40
      t.column :rank,       :integer, :limit => 4
      t.column :ticket_property_type_id, :integer
    end
    add_index :ticket_properties, :rank
    add_index :ticket_properties, :ticket_property_type_id

    create_table :ticket_properties_tickets, :id => false do |t|
      t.column :ticket_id, :integer
      t.column :ticket_property_id, :integer
    end
    add_index :ticket_properties_tickets, [:ticket_id, :ticket_property_id], :unique => true, :name => 'uidx_ticket_properties_tickets'
        
        
    Project.reflections[:ticket_property_types].options.delete(:order)
    Project.reflections[:ticket_properties].options.delete(:order)
    TicketPropertyType.reflections[:ticket_properties].options.delete(:order)
    [Release, Component].each do |klass|

      Project.find(:all).each do |project|
        project.ticket_property_types.find_by_name(klass.name, :include => [:ticket_properties]) ||
        project.ticket_property_types.create!( :name => klass.name )
      end

      counter = 0
      klass.find(:all, :order => 'id').each do |record|
        type = record.project.ticket_property_types.find_by_name(klass.name, :include => [:ticket_properties])
        property = type.ticket_properties.create( :name => record.name, :rank => counter += 1 )        
        Ticket.send("find_all_by_#{klass.name.downcase}_id", record.id).each do |ticket|
          ticket.ticket_properties << property
        end        
      end    
    end
  end

  def self.down
    drop_table :ticket_property_types
    drop_table :ticket_properties
    drop_table :ticket_properties_tickets
  end
end
