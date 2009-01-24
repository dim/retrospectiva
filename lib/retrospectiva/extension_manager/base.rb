module Retrospectiva
  module ExtensionManager
    class Base
          
      def load_routes!      
        installed_extensions.each do |extension|
          extension.load_routes!  
        end      
      end
  
      def load_locales!
        installed_extensions.each do |extension|
          extension.load_locales!  
        end
      end
  
      def load_paths!
        installed_extensions.each do |extension|
          extension.load_paths!  
        end
        ActionController::Routing.controller_paths << RAILS_ROOT + '/lib/retrospectiva/extension_manager/controllers'
        ActionController::Routing.controller_paths.uniq!
        ActiveSupport::Dependencies.load_paths.uniq!
        ActiveSupport::Dependencies.load_paths.reverse_each do |dir| 
          $LOAD_PATH.unshift(dir) if File.directory?(dir)
        end
        $LOAD_PATH.uniq!
      end    
  
      # Returns the path the extensions are stored in
      def extension_path(name = nil)
        path = File.join(RAILS_ROOT, 'extensions')
        path = File.join(path, name.to_s) if name
        path
      end
  
      def available_extensions
        Dir[extension_path('*')].sort.map do |path|
          Extension.load(path)
        end.compact
      end
  
      def installed_extensions
        ExtensionInstaller.installed_extension_names.map do |name|
          Extension.load(name)
        end.compact
      end
  
      def install_extension(name, skip_migration = false, force_migration = false)
        extension = Extension.load(name)
        return unless extension
        
        ExtensionInstaller.install(extension)      
        begin 
          extension.migrate(:up)
        rescue ActiveRecord::StatementInvalid
          raise if force_migration
        end unless skip_migration
      end
  
      def uninstall_extension(name, skip_migration = true, force_migration = false)
        extension = Extension.load(name)
        return unless extension
        
        ExtensionInstaller.uninstall(extension)      
        begin 
          extension.migrate(:down)
        rescue ActiveRecord::StatementInvalid
          raise if force_migration
        end unless skip_migration
      end
  
      def checkout_extension(url, externalize = true)
        return "Your installation is not using Subversion" unless File.directory?("#{extension_path}/.svn")
  
        name = ExtensionInstaller.checkout(url)      
        if externalize && available_extensions.map(&:name).include?(name)
          ExtensionInstaller.externalize(name, url)
        end
        nil
      end
    
    end
  end
end 
