require 'blueprint/css_parser'

module ActionView
  module Helpers #:nodoc:
    module AssetTagHelper
      
      private
        def join_asset_file_contents_with_additional_compression(paths)
          content = join_asset_file_contents_without_additional_compression(paths)
          File.extname(paths.first).starts_with?('.css') ? Blueprint::CSSParser.new(content).to_s : content
        end
        alias_method_chain :join_asset_file_contents, :additional_compression

    end
  end
end