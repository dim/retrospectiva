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
      returning yield do |result|
        result.gsub!(/^\/projects\/#{Regexp.escape(Project.central.to_param)}(.+)$/, '\1') if Project.central
      end
    end

  end
end