require 'tempfile'

module Retrospectiva
  module ExtensionManager
    module ExtensionInstaller
      include ActiveSupport::Memoizable
      extend self
      
      CONFIG_FILE = File.join(RAILS_ROOT, 'config', 'runtime', 'extensions.yml')
            
      def install(extension)
        @installed_extension_names << extension.name
        write_extension_table
      end

      def uninstall(extension)
        @installed_extension_names.delete(extension.name)
        write_extension_table
      end
      
      def download(uri)
        name = File.basename(uri.split('/').last, '.git')
        if system("git clone #{uri} #{extension_path(name)}")
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

        def extension_path(name = nil)
          ExtensionManager.extension_path(name)
        end   

    end
  end
end 
  