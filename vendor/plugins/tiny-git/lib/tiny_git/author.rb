module TinyGit
  class Author
    attr_accessor :name, :email, :date
    
    PATTERNS = {
      /(.*?) <(.*?)> (\d+) (.*)/ => lambda {|v| Time.at(v.to_i) }, 
      /(.*?) <(.*?)> (\w{3}, \d{1,2} \w{3} \d{4} [\d:]{8} [+-]\d{4})/ => lambda {|v| Time.parse(v) }   
    }
    
    def initialize(author_string)
      PATTERNS.each do |pattern, proc|        
        if m = pattern.match(author_string)
          @name = m[1]
          @email = m[2]
          @date = proc.call(m[3])
          break
        end
      end
    end
    
  end
end