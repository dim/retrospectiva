module ActionView
  module Helpers #:nodoc:
    module AssetTagHelper
      
      private
        def write_asset_file_contents(joined_asset_path, asset_paths)
          unless file_exist?(joined_asset_path)
            FileUtils.mkdir_p(File.dirname(joined_asset_path))
            content = join_asset_file_contents(asset_paths)
            if joined_asset_path.ends_with?('.css')
              content = Blueprint::CSSParser.new(content).to_s    
            elsif joined_asset_path.ends_with?('.js')
              content # = Packr.new.pack(content)    
            end
            File.open(joined_asset_path, "w+") {|cache| cache.write(content) } 
          end
        end
    end
  end
end
