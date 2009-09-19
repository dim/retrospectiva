require 'tempfile'
require 'yaml'

module Retrospectiva
  module ExtensionManager
    module ExtensionInstaller
      include ActiveSupport::Memoizable
      extend self
      
      CONFIG_FILE = File.join(RAILS_ROOT, 'config', 'runtime', 'extensions.yml')
            
      def install(extension)
        @installed_extension_names << extension.name
        returning write_extension_table do
          dump_schema
        end
      end

      def uninstall(extension)
        @installed_extension_names.delete(extension.name)        
        returning write_extension_table do
          dump_schema
        end
      end
      
      def download(uri)
        name = File.basename(uri, '.git').split('.').last
        if system("git clone --depth 1 #{uri} #{extension_path(name)}")
          FileUtils.rm_rf File.join(extension_path(name), ".git")
          true
        else
          false
        end
      end

      def installed_extension_names
        @installed_extension_names ||= if RAILS_ENV == 'test'
          ENV['RETRO_EXT'].to_s.split(/[\s,]+/).reject(&:blank?) 
        else
          YAML.load_configuration(CONFIG_FILE, [])
        end
      end

      private

        def write_extension_table
          sanitize!
          File.open(CONFIG_FILE, 'w') do |f| 
            YAML.dump(installed_extension_names, f )
          end            
        end

        def sanitize!
          valid_names = ExtensionManager.available_extensions.map(&:name)
          @installed_extension_names = (installed_extension_names & valid_names).uniq
        end
        
        def dump_schema
          require 'active_record/schema_dumper'
          File.open("#{RAILS_ROOT}/db/schema.rb", "w") do |file|
            ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
          end        
        end

        def extension_path(name = nil)
          ExtensionManager.extension_path(name)
        end   

    end
  end
end 
  