module Grit    
  class Blob
    def acts_like_node?; true; end    
  end

  class Tree
    def acts_like_node?; true; end    
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
end
