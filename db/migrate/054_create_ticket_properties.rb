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
        
   
    project_ids = select_all("SELECT id FROM projects").map {|i| i['id'].to_i }   
    components = select_all("SELECT id, name FROM components")
    releases = select_all("SELECT id, name FROM releases")
    
    project_ids.each do |project_id|  
        
      counter = 0
      component_type_id = insert_sql "INSERT INTO ticket_property_types (name, project_id) VALUES ('Component', #{project_id})"
      components.each do |component|
        property_id = insert_sql "INSERT INTO ticket_properties (name, ticket_property_type_id, rank) VALUES ('#{component['name']}', #{component_type_id}, #{counter+=1})"
        select_all("SELECT id FROM tickets WHERE project_id = #{project_id} AND component_id = #{component['id']}").each do |ticket|
          insert_sql "INSERT INTO ticket_properties_tickets (ticket_id, ticket_property_id) VALUES (#{ticket['id']}, #{property_id})"
        end
      end

      counter = 0
      release_type_id = insert_sql "INSERT INTO ticket_property_types (name, project_id) VALUES ('Release', #{project_id})"
      releases.each do |release|
        property_id = insert_sql "INSERT INTO ticket_properties (name, ticket_property_type_id, rank) VALUES ('#{release['name']}', #{release_type_id}, #{counter+=1})"
        select_all("SELECT id FROM tickets WHERE project_id = #{project_id} AND release_id = #{release['id']}").each do |ticket|
          insert_sql "INSERT INTO ticket_properties_tickets (ticket_id, ticket_property_id) VALUES (#{ticket['id']}, #{property_id})"
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
