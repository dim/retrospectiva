module Grit  
    
  mattr_accessor :query_cache, :query_cache_enabled
  self.query_cache_enabled = false
  self.query_cache = {}
  
  def self.cache
    self.query_cache_enabled = true
    yield
  ensure
    self.query_cache.clear
    self.query_cache_enabled = false
  end
      
  class Git

    def sh_with_query_cache(command)
      if Grit.query_cache_enabled
        cache_query(command) { sh_without_query_cache(command) }
      else
        sh_without_query_cache(command)
      end
    end
    alias_method_chain :sh, :query_cache
    
    def wild_sh_with_query_cache(command)
      if Grit.query_cache_enabled
        cache_query(command) { wild_sh_without_query_cache(command) }
      else
        wild_sh_without_query_cache(command)
      end
    end
    alias_method_chain :wild_sh, :query_cache

    private

      def cache_query(command)        
        if Grit.query_cache.has_key?(command)
          log_cached_command(command, 0, true)
          Grit.query_cache[command]
        else
          result = nil
          seconds = Benchmark.realtime do
            result = Grit.query_cache[command] = yield  
          end          
          log_cached_command(command, seconds, false)
          result
        end
      end
    
      def log_cached_command(command, seconds, cached = false)
        time = "(#{sprintf("%.1f", seconds * 1000)}ms)"
        message = cached ? "  Grit CACHE #{time}  #{command}" : "  Grit Query #{time}  #{command}"
        ActiveRecord::Base.logger.debug(message)
      end
        
  end
  
  
  class Commit
    FILE_CHANGE_PATTERN = %r|
      \:
      (\d+)\s*                       # a_mode
      (\d+)\s*                       # b_mode      
      (\w+)[\.\s]*                   # a_commit      
      (\w+)[\.\s]*                   # b_commit      
      ([A-Z])[\d\s]*                 # type
      (#{URI::PATTERN::REL_PATH})\s* # a_path
      (#{URI::PATTERN::REL_PATH})?   # b_path
    |x

    def file_changes
      arg = parents.empty? ? @id : "#{parents.first.id}..#{@id}"
      text = @repo.git.log({:M => true, :raw => true, :find_copies_harder => true}, arg)      
      text.scan(FILE_CHANGE_PATTERN).map do |tokens|        
        FileChange.new(@repo, *tokens)
      end
    end    
  end
  
  
  class FileChange < Diff
    attr_reader :type
    
    def initialize(repo, a_mode, b_mode, a_commit, b_commit, type, a_path, b_path)
      @type = type
      super(repo, a_path, b_path, a_commit, b_commit, a_mode, b_mode, type == 'A', type == 'D', nil)
    end
    
    def inspect
      "#<#{self.class.name}[#{type}] #{a_info} #{b_info}>"
    end
    
    def a_info
      "#{a_path}(#{a_mode}:#{a_commit})"
    end

    def b_info
      b_path ? "#{b_path}(#{b_mode}:#{b_commit})" : nil
    end
    
  end
  
end if SCM_GIT_ENABLED