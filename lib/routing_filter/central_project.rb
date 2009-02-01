module RoutingFilter
  class CentralProject < Base

    def around_recognize(path, environment, &block)      
      if !path.starts_with?("/projects/") and Project.central 
        ActionController::Routing::Routes.recognize_path("/projects/#{Project.central.to_param}" + path, environment) rescue yield
      else
        yield
      end      
    end
        
    def around_generate(*args, &block)
      returning yield do |path|
        if Project.central and path != "/projects/#{Project.central.to_param}.rss"
          path.gsub!(/^\/projects\/#{Regexp.escape(Project.central.to_param)}(.+)$/, '\1')
        end
      end
    end

  end
end