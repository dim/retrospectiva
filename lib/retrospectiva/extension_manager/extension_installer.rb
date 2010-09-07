require 'tempfile'
require 'yaml'

module Retrospectiva
  module ExtensionManager
    module ExtensionInstaller
      extend self
      delegate :extension_path, :available_extensions, :to => :"Retrospectiva::ExtensionManager"

      def install(extension)
        return if installed_extension_names.include?(extension.name) 

        @installed_extension_names << extension.name
        write_extension_table.tap do
          dump_schema
        end
      end

      def uninstall(extension)
        return unless installed_extension_names.include?(extension.name)

        @installed_extension_names.delete(extension.name)        
        write_extension_table.tap do
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
        @installed_extension_names ||= read_extension_table
      end
      
      def reload
        @installed_extension_names = nil
        installed_extension_names
      end

      private

        def config_file
          Rails.root.join('config', 'runtime', 'extensions.yml')
        end

        def test_mode?
          Rails.env.test?
        end

        def read_extension_table
          if test_mode?
            ENV['RETRO_EXT'].to_s.split(/[\s,]+/).reject(&:blank?)
          else
            YAML.load_configuration(config_file, [])
          end
        end

        def write_extension_table
          sanitize!
          File.open(config_file, 'w') do |f| 
            YAML.dump(installed_extension_names, f )
          end            
        end

        def sanitize!
          @installed_extension_names = (installed_extension_names & available_extensions.map(&:name)).uniq
        end
        
        def dump_schema
          require 'active_record/schema_dumper'
          File.open("#{RAILS_ROOT}/db/schema.rb", "w") do |file|
            ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
          end        
        end

    end
  end
end 
  