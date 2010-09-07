module Retrospectiva
  module ExtensionManager
    DependenciesExtension = lambda do

      def require_or_load_with_extensions(file_name, const_path = nil)
        loaded = require_or_load_without_extensions(file_name, const_path)
        file_name = remove_path_prefix(file_name)
        RetroEM.installed_extensions.each do |extension|          
          path = File.join(extension.root_path, 'ext', file_name)
          require_or_load(path) if File.exists?(path)
        end if file_name
        loaded
      end
      alias_method_chain :require_or_load, :extensions        

      def remove_path_prefix(file_name)
        autoload_paths.reverse_each do |root|
          return file_name.gsub(/^#{Regexp.escape(root)}\/?/, '') if file_name.starts_with?(root)
        end
        nil
      end
      protected :remove_path_prefix
        
    end
  end
end
