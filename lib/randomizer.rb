module Randomizer
  extend self
  
  def string(size = 8)
    size -= 1
    [Array.new(size){rand(256).chr}.join].pack('m')[0..size]  
  end

  def pronounceable(size = 12)
    chars = [ char(:c) + char(:v) ]
    (size / 2).to_i.times do 
      chars << cchars + char(:v)
    end
    chars.join.first(size)
  end
    
  private
  
    def char(type)
      set = (type == :v) ? ['a','e','i','o','u'] : ['b','c','d','f','g','k','l','m','n','p','r','s','t','w']
      set[rand(set.size)].send(rand(3).zero? ? :upcase : :downcase)
    end
    
    def cchars
      rand(3).zero? ? char(:c) : char(:c) + char(:c)
    end

end