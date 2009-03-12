class DropSchemaInfoTable < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.tables.include?('schema_info')
      drop_table(:schema_info)
    end
  end

  def self.down
    create_table "schema_info", :id => false, :force => true do |t|
      t.integer "version"
    end
  end
end
