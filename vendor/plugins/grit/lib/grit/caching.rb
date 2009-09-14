module Grit
  
  class << self    
  
    attr_accessor :result_cache, :cache_enabled
    
    def cache
      old_value = self.cache_enabled
      self.cache_enabled = true
      yield
    ensure
      self.cache_enabled = old_value
      self.result_cache.clear
    end    

  end
  
  self.cache_enabled = false
  self.result_cache = {}
          
  module ResultCache
    
    def execute_with_cache(call, timeout = nil)
      return execute_without_cache(call, timeout) unless Grit.cache_enabled
        
      result = Grit.result_cache[call]
      if result
        Grit.logger.debug "  Grit 0.0ms  #{call}"
        result
      else
        Grit.result_cache[call] = execute_without_cache(call, timeout) 
      end
    end
  
  end
  
  class Git
    include ResultCache
    alias_method :execute_without_cache, :execute
    alias_method :execute, :execute_with_cache    
  end
end