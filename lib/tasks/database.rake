require 'fileutils'

# Create a schema.rb file if it is missing
if defined?(RAILS_ROOT) && !File.exist?(File.join(RAILS_ROOT, 'db', 'schema.rb'))
  FileUtils.cp File.join(RAILS_ROOT, 'db', 'schema.core.rb'), File.join(RAILS_ROOT, 'db', 'schema.rb')
end 

namespace :db do
  namespace :retro do
    task :load do
      STDERR.puts "Task db:retro:load is deprecated and was disabled; please use db:setup instead."
    end
  end
end
