require 'retrospectiva/access_manager/menu_map'
require 'retrospectiva/access_manager/permission_map'
require 'retrospectiva/access_manager/secure_controller'

module Retrospectiva
  module AccessManager
    class Error < StandardError # :nodoc:
    end
    class NoAuthorizationError < Retrospectiva::AccessManager::Error # :nodoc:
    end
  
    extend self
    
    def menu_map
      unless @menu_map
        @menu_map = MenuMap.new
        preload_controllers!
      end
      @menu_map
    end

    def permission_map(&block)
      @permission_map ||= PermissionMap.new
      yield @permission_map if block_given?
      @permission_map
    end
  
    def menu_items
      menu_map.values.sort_by(&:rank)
    end
    
    def menu_links
      @menu_links ||= {}
    end

    def sorted_menu_items(ranked_names = nil)
      ranked_names ||= []
      menu_items.sort_by do |item|
        rank = ranked_names.index(item.name) || ranked_names.size
        [rank, item.rank, _(item.label)]
      end
    end

    def load!
      load File.join(RAILS_ROOT, 'app', 'core_info.rb')      
      RetroEM.installed_extensions.each do |extension|
        extension.load_info!      
      end
    end
    
    def reload!
      load!
      @preloaded_controllers = nil
      preload_controllers!
    end
    
    def preload_controllers!
      @preloaded_controllers ||= ActionController::Routing.controller_paths.each do |path|
        Dir[File.join(path, '*_controller.rb')].each do |file|            
          File.basename(file, '.rb').classify.constantize
        end   
      end && true
    end
    private :preload_controllers!
            
  end
end

RetroAM = Retrospectiva::AccessManager

ActionController::Base.class_eval do
  private
  include Retrospectiva::AccessManager::SecureController
  rescue_responses.update('Retrospectiva::AccessManager::NoAuthorizationError' => :forbidden)
end

ActionController::Base.class_eval do
  prepend_before_filter :reload_retrospectiva_controllers!
  private
    def reload_retrospectiva_controllers!
      RetroAM.reload!
    end
end if RAILS_ENV != 'production'
