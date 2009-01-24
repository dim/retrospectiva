class MigrateRepositoryTypesToRails22Format < ActiveRecord::Migration
  def self.up
    select_all("SELECT DISTINCT type FROM repositories").map(&:values).flatten.each do |type|
      next if type.starts_with?('Repository::')
      execute "UPDATE repositories SET type = 'Repository::#{type}' WHERE type = '#{type}'" 
    end
  end

  def self.down
    select_all("SELECT DISTINCT type FROM repositories").map(&:values).flatten.each do |type|
      next unless type.starts_with?('Repository::')
      execute "UPDATE repositories SET type = '#{type.demodulize}' WHERE type = '#{type}'" 
    end
  end
end
