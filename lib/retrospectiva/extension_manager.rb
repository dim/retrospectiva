require 'retrospectiva/extension_manager/core_ext/dependencies'
require 'retrospectiva/extension_manager/core_ext/controller'
require 'retrospectiva/extension_manager/core_ext/asset_tag_helper'

require 'retrospectiva/extension_manager/routes'
require 'retrospectiva/extension_manager/views'
require 'retrospectiva/extension_manager/extension'
require 'retrospectiva/extension_manager/extension_installer'

require 'retrospectiva/extension_manager/controllers/retrospectiva_extension_assets_controller'
  
module Retrospectiva
  module ExtensionManager
    extend self 
    
    def load!(config)
      load_core_extensions!      
      installed_extensions.each do |extension|
        extension.load_locales!
        extension.load_routes!

        config.controller_paths += extension.controller_paths 
        config.eager_load_paths += extension.load_paths
        
        ActiveSupport::Dependencies.autoload_paths += extension.load_paths
        ActionController::Base.prepend_view_path(extension.view_paths)

        extension.load_paths.reverse_each { |dir| $LOAD_PATH.unshift(dir) }        
      end
      ActiveSupport::Dependencies.clear
      $LOAD_PATH.uniq!
      I18n.reload!
      @loaded = true
    end
    
    def loaded?
      @loaded == true
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
      @installed_extensions ||= ExtensionInstaller.installed_extension_names.map do |name|
        Extension.load(name)
      end.compact
    end

    def install_extension(name, skip_migration = false, force_migration = false)
      extension = Extension.load(name)
      return unless extension
      
      ExtensionInstaller.install(extension)
      @installed_extensions = nil
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
      @installed_extensions = nil
      begin 
        extension.migrate(:down)
      rescue ActiveRecord::StatementInvalid
        raise if force_migration
      end unless skip_migration
    end

    def download_extension(uri)
      ExtensionInstaller.download(uri)      
    end

    def load_core_extensions!
      ActionController::Base.extend(Retrospectiva::ExtensionManager::ControllerExtension)      
      ActiveSupport::Dependencies.class_eval(&Retrospectiva::ExtensionManager::DependenciesExtension)
    end
    private :load_core_extensions!

  end
end 

RetroEM = Retrospectiva::ExtensionManager
