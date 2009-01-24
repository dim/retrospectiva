class MigrateToInnodb < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.class.name.demodulize == 'MysqlAdapter'
      tables.each do |name|
        execute "ALTER TABLE #{name} ENGINE=InnoDB"
      end
    end
  end

  def self.down
  end
end
