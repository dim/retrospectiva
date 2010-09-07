module RoutingFilter
  class CentralProject < Base

    def around_recognize(path, environment, &block)
      if !path.starts_with?("/projects") and Project.central 
        ActionController::Routing::Routes.recognize_path("/projects/#{Project.central.short_name}" + path, environment) rescue yield
      else
        yield
      end      
    end
        
    def around_generate(*args, &block)
      yield.tap do |result|
        path = result.is_a?(Array) ? result.first : result # In case generate_extras returns an Array         
        if Project.central and path !~ /^#{central_project_expression}\.rss/
          path.sub!(/^#{central_project_expression}(.+)$/, '\1\2')
        end
      end
    end

    private
      
      delegate :relative_url_root, :to => :'ActionController::Base'
      
      def central_project_expression
        expression = Regexp.escape("/projects/") + Regexp.escape(Project.central.short_name)
        if relative_url_root.present?
          "(#{relative_url_root})?#{expression}"
        else
          expression
        end
      end

  end
end