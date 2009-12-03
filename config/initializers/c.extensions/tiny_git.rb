module TinyGit
  module Caching
    class Middleware
      
      def initialize(app)
        @app = app
      end
  
      def call(env)
        TinyGit.cache do
          @app.call(env)
        end
      end
            
    end
  end
  
  Rails.configuration.middleware.use Caching::Middleware
end if SCM_GIT_ENABLED


