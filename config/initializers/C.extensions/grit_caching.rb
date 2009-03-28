module ActionController #:nodoc:
  module Caching
    module GritCache
      
      def self.included(base) #:nodoc:
        base.alias_method_chain :perform_action, :grit_caching
      end

      protected
      
        def perform_action_with_grit_caching
          Grit.cache do
            perform_action_without_grit_caching
          end
        end
    
    end
  end
end if SCM_GIT_ENABLED

ActionController::Base.class_eval do
  include ActionController::Caching::GritCache
end if SCM_GIT_ENABLED and ActionController::Base.cache_configured?