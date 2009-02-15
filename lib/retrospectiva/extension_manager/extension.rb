module Retrospectiva
  module ExtensionManager  
    class Extension

      def self.load(name_or_path)
        path = name_or_path =~ /^\w+$/ ? ExtensionManager.extension_path(name_or_path) : name_or_path         
        extension = new(path)
        extension.info? ? extension : nil
      end
     
      attr_reader :root_path
      
      def initialize(path)
        @root_path = File.expand_path(path)
      end

      def name
        File.basename(root_path)
      end
         
      def installed?
        ExtensionManager.installed_extensions.include?(self)
      end
      
      def info?
        File.exists?(info_path)
      end

      def load_routes!
        load routes_path if File.exists?(routes_path)         
      end  
      
      def load_locales!
        locales = File.join(root_path, 'locales', '**', '*.{rb,yml}')
        Dir[locales].uniq.each do |file|
          I18n.load_path << file
        end
      end
      
      def controller_paths
        [File.join(root_path, 'lib')].select do |path|
          File.directory?(path)          
        end
      end

      def load_paths
        [File.join(root_path, 'lib'), File.join(root_path, 'models')].select do |path|
          File.directory?(path)          
        end
      end
      
      def view_paths
        [File.join(root_path, 'views')].select do |path|
          File.directory?(path)          
        end        
      end            
            
      def load_info!
        load(info_path) if info?
      end
     
      def eql?(other)
        self.name == other.name        
      end
      alias_method :==, :eql?
      
      def migrate(direction = :up)
        migration_path = File.join(root_path, 'migrate')
        if File.directory?(migration_path)
          ActiveRecord::Migrator.new(direction, migration_path).migrate
        end
      end

      def assets?
        File.directory?(public_path)
      end

      def public_path(*tokens)
        File.join(root_path, 'public', *tokens)
      end

      def settings_path
        File.join(root_path, 'ext_settings.yml')
      end

      private
      
        def info_path
          File.join(root_path, 'ext_info.rb')
        end
      
        def routes_path
          File.join(root_path, 'routes.rb')
        end

    end
  end
end