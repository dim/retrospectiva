namespace :db do

  namespace :retro do
    desc 'Loads the database schema and the initial content'
    task :load => :environment do
      Rake::Task['db:retro:load_schema'].invoke
      Rake::Task['db:retro:load_content'].invoke
    end

    desc 'Loads the database schema'
    task :load_schema => :environment do
      puts "\n===== Load the database schema\n"
      ENV['SCHEMA'] ||= "#{RAILS_ROOT}/db/schema.core.rb"
      Rake::Task["db:schema:load"].invoke
    end

    desc 'Loads the initial content'
    task :load_content => :environment do
      puts "\n===== Load the initial content\n"
      load(RAILS_ROOT + "/db/default_content.rb")
    end
  end
end

