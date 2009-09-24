require 'uri'

module TinyGit
  class Change
    PATTERN = %r|
      \:
      (\d+)\s*                       # a_mode
      (\d+)\s*                       # b_mode      
      (\w+)[\.\s]*                   # a_commit      
      (\w+)[\.\s]*                   # b_commit      
      ([A-Z])[\d\s]*                 # type
      (#{URI::PATTERN::REL_PATH})\s* # a_path
      (#{URI::PATTERN::REL_PATH})?   # b_path
    |x
    
  
    def self.parse(line)
      line.scan(PATTERN).map do |tokens|
        new(*tokens)
      end    
    end
    
    attr_reader :type, :a_mode, :b_mode, :a_commit, :b_commit, :a_path, :b_path
    
    def initialize(a_mode, b_mode, a_commit, b_commit, type, a_path, b_path)
      @a_mode, @b_mode, @a_commit, @b_commit, @type, @a_path, @b_path = a_mode, b_mode, a_commit, b_commit, type, a_path, b_path
    end

  end  
end