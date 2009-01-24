module ParamsKeeper
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def keep_params!(options = {})
      extend SingletonMethods
      include InstanceMethods
      options_for_params_keeper.merge! :exclude => [options.delete(:exclude)].flatten.compact.uniq
      prepend_before_filter :params_keeper_retrieve, options
      append_after_filter   :params_keeper_store,    options
    end
  end

  module SingletonMethods
    def options_for_params_keeper
      @options_for_params_keeper ||= {}
    end
  end
  
  module InstanceMethods
    def params_keeper_key
      "#{self.class.controller_path}/#{action_name}"
    end  
    
    def params_keeper_retrieve
      stored = session[:params_keeper][params_keeper_key] rescue {}
      if stored && stored.keys.any? && (stored.keys & params.keys).blank?
        params.merge!(stored)
      end
      true
    end
  
    def params_keeper_store
      exclude_keys = [:controller, :action, :format] + self.class.options_for_params_keeper[:exclude]
      session[:params_keeper] ||= {}
      session[:params_keeper][params_keeper_key] = params.except(*exclude_keys)
      true
    end
  
    private :params_keeper_retrieve, :params_keeper_store, :params_keeper_key
  end
end

ActionController::Base.send :include, ParamsKeeper