module Retrospectiva
  module ExtensionManager
    module AssetTagHelper
      
      def x_javascript_include_tag(*sources)        
        options = sources.extract_options!.stringify_keys
        expand_javascript_sources(sources, options.delete("recursive")).collect do |source|
          x_javascript_src_tag(source, options)
        end.join("\n")
      end
            
      def x_stylesheet_link_tag(*sources)
        options = sources.extract_options!.stringify_keys
        expand_stylesheet_sources(sources, options.delete("recursive")).map do |source|
          x_stylesheet_tag(source, options)
        end.join("\n")
      end
    
      def x_image_tag(source, options = {})
        options.symbolize_keys!

        options[:src] = x_image_path(source)
        options[:alt] ||= File.basename(options[:src], '.*').split('.').first.to_s.capitalize

        if size = options.delete(:size)
          options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
        end

        if mouseover = options.delete(:mouseover)
          options[:onmouseover] = "this.src='#{x_image_path(mouseover)}'"
          options[:onmouseout]  = "this.src='#{x_image_path(options[:src])}'"
        end

        tag("img", options)
      end
      
      private

        def x_javascript_src_tag(source, options)
          content_tag("script", "", { "type" => Mime::JS, "src" => x_javascript_path(source) }.merge(options))
        end

        def x_stylesheet_tag(source, options)
          tag("link", { "rel" => "stylesheet", "type" => Mime::CSS, "media" => "screen", "href" => html_escape(x_stylesheet_path(source)) }.merge(options), false, false)
        end

        def x_javascript_path(source)
          compute_public_path(source, "extensions/#{@controller.class.retrospectiva_extension}/javascripts", 'js')
        end

        def x_stylesheet_path(source)
          compute_public_path(source, "extensions/#{@controller.class.retrospectiva_extension}/stylesheets", 'css')
        end
      
        def x_image_path(source)
          compute_public_path(source, "extensions/#{@controller.class.retrospectiva_extension}/images")
        end
      
    end
  end
end
