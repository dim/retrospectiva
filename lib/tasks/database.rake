namespace :db do 

  namespace :retro do
    task :load do
      STDERR.puts "Task db:retro:load is deprecated and was disabled; please use db:setup instead."
    end
  end
  
  namespace :schema do  
    # Copy schema.core.rb to schema.rb if missing
    task :clone_core => :environment do
      unless File.exist?(Rails.root.join('db', 'schema.rb'))
        FileUtils.cp Rails.root.join('db', 'schema.core.rb'), Rails.root.join('db', 'schema.rb')
      end
    end
  end
 
end

Rake::Task['db:schema:load'].enhance ['db:schema:clone_core']
