class DropSchemaInfoTable < ActiveRecord::Migration
  def self.up
    begin
      drop_table :schema_info
    rescue ActiveRecord::StatementInvalid
    end
  end

  def self.down
    create_table "schema_info", :id => false, :force => true do |t|
      t.integer "version"
    end
  end
end
