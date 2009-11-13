module ParamsKeeper
  
  EXCLUDE_KEYS = [:controller, :action, :id, :format, :_clear].freeze
  CLEAN_KEYS = lambda {|i| [i].flatten.compact.uniq.map(&:to_s) }
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def keep_params!(options = {})
      extend SingletonMethods
      include InstanceMethods
      options_for_params_keeper.update(
        :include => CLEAN_KEYS.call(options.delete(:include)),
        :exclude => CLEAN_KEYS.call(options.delete(:exclude))
      )
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
      params_keeper_reset and return true if params[:_clear]
      
      stored = session[:params_keeper][params_keeper_key] rescue {}
      if stored && stored.keys.any? && (stored.keys & params.keys).blank?
        params.update(stored)
      end
      true
    end
  
    def params_keeper_store
      exclude_keys = if self.class.options_for_params_keeper[:include].any?
        params.keys - self.class.options_for_params_keeper[:include]
      else
        ParamsKeeper::EXCLUDE_KEYS + self.class.options_for_params_keeper[:exclude]
      end
      
      session[:params_keeper] ||= {}
      session[:params_keeper][params_keeper_key] = params.except(*exclude_keys)        
      true
    end
  
    def params_keeper_reset
      session[:params_keeper] ||= {}
      session[:params_keeper][params_keeper_key] = {}
    end
    
    private :params_keeper_retrieve, :params_keeper_store, :params_keeper_key, :params_keeper_reset
  end
end
