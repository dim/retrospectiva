module TinyGit
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
    
  class Repo
    private
    
      def run_command_with_cache(call)
        return run_command_without_cache(call) unless TinyGit.cache_enabled?
          
        result = TinyGit.result_cache[call]
        if result
          @logger.debug "  TinyGit CACHED (0.0ms)  #{call}" if @logger
          result
        else
          TinyGit.result_cache[call] = run_command_without_cache(call) 
        end
      end
      alias_method :run_command_without_cache, :run_command
      alias_method :run_command, :run_command_with_cache

  end
end