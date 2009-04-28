class MigrateRepositoryTypesToRails22Format < ActiveRecord::Migration
  def self.up
    select_all("SELECT DISTINCT type FROM repositories").map(&:values).flatten.each do |type|
      next if type.starts_with?('Repository::')
      new_type = "Repository::#{type}"      
      execute "UPDATE repositories SET type = #{quote(new_type)} WHERE type = #{quote(type)}" 
    end
  end

  def self.down
    select_all("SELECT DISTINCT type FROM repositories").map(&:values).flatten.each do |type|
      next unless type.starts_with?('Repository::')
      new_type = type.demodulize
      execute "UPDATE repositories SET type = #{quote(new_type)} WHERE type = #{quote(type)}" 
    end
  end
end
