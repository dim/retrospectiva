module Grit
  @@result_cache = {}
  @@cache_enabled = false
  
  class << self    
    
    def cache_enabled?
      @@cache_enabled == true
    end
    
    def result_cache
      @@result_cache
    end
  
    def cache
      old_value = @@cache_enabled
      @@cache_enabled = true
      yield
    ensure
      @@cache_enabled = old_value
      @@result_cache.clear
    end

  end
    
  class Git

    def execute_with_cache(call, timeout = nil)
      return execute_without_cache(call, timeout) unless Grit.cache_enabled?
        
      result = Grit.result_cache[call]
      if result
        Grit.logger.debug "  Grit (0.0ms CACHED)  #{call}"
        result
      else
        Grit.result_cache[call] = execute_without_cache(call, timeout) 
      end
    end
    alias_method :execute_without_cache, :execute
    alias_method :execute, :execute_with_cache    

  end
end