module Grit
  module Caching
    class Middleware
      
      def initialize(app)
        @app = app
      end
  
      def call(env)
        Grit.cache do
          @app.call(env)
        end
      end
            
    end
  end
end if SCM_GIT_ENABLED

Rails.configuration.middleware.use Grit::Caching::Middleware if SCM_GIT_ENABLED
