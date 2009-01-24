module Retrospectiva
  module ExtensionManager  
    module Routes
      
      mattr_accessor :routes
      self.routes = []
      
      def self.draw(&block)
        routes << block
      end 

      def self.clear
        routes.clear
      end
      
      def self.apply(map)
        routes.each do |block|
          block.call(map)
        end

        RetroEM.installed_extensions.each do |extension|
          next unless extension.assets?
          map.connect "extensions/#{extension.name}/:asset_type/*path", :controller => 'retrospectiva_extension_assets', :action => 'show', :extension => extension.name 
          map.connect "extensions/#{extension.name}/*path", :controller => 'retrospectiva_extension_assets', :action => 'show', :extension => extension.name
        end
      end
      
    end
  end
end
