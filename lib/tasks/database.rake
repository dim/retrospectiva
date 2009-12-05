require 'fileutils'

namespace :db do
  namespace :retro do
    task :load do
      STDERR.puts "Task db:retro:load is deprecated and was disabled; please use db:setup instead."
    end
  end
end

Rake::Task['db:setup'].enhance do

  # Create a schema.rb file if it is missing
  unless File.exist?(File.join(File.dirname(__FILE__), '..', 'db', 'schema.rb'))
    FileUtils.cp File.join(File.dirname(__FILE__), '..', 'db', 'schema.core.rb'), File.join(File.dirname(__FILE__), '..', 'db', 'schema.rb')
  end
  
end
