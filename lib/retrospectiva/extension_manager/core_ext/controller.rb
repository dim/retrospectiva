module Retrospectiva
  module ExtensionManager
    module ControllerExtension

      def retrospectiva_extension(name = nil)
        if name
          add_template_helper(Retrospectiva::ExtensionManager::AssetTagHelper)
          @retrospectiva_extension = name  
        end
        @retrospectiva_extension
      end
  
    end
  end  
end
