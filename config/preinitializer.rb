require 'fileutils'

# Create a schema.rb file if it is missing
unless File.exist?(File.join(File.dirname(__FILE__), '..', 'db', 'schema.rb'))
  FileUtils.cp File.join(File.dirname(__FILE__), '..', 'db', 'schema.core.rb'), File.join(File.dirname(__FILE__), '..', 'db', 'schema.rb')
end