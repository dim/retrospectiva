module WikiEngine

  class << self
    
    def parse_wiki_word_link(match_data, &block)
      engine = select_engine(engine)
      engine.blank? ? match_data[0] : supported_engines[engine].parse_wiki_word_link(match_data, &block)
    end
    
    def wiki_word_pattern(engine = nil)
      engine = select_engine(engine)
      engine.blank? ? %r{} : supported_engines[engine].wiki_word_pattern
    end
  
  end

  class AbstractEngine 
    
    WIKI_WORD_PATTERN = /
      \[\[
      (?:(F|I)[\|\:])?
      (\\?[ \w-]{2,})
      (?:[\|\:]([^\]]+))?
      \]\]
    /x.freeze unless const_defined?(:WIKI_WORD_PATTERN)
    
    def wiki_word_pattern
      WIKI_WORD_PATTERN
    end

    def parse_wiki_word_link(match_data, &block)
      prefix, page, title = extract_wiki_word_parts(match_data)
      page = page.to_s.gsub(/ +/, ' ').strip
      title = title.blank? ? page : title.strip
      page.starts_with?('\\') ? match_data[0].gsub(/\\/, '') : yield(prefix, page, title)      
    end
  
    def extract_wiki_word_parts(match_data)      
      match_data[-3..-1]
    end

  end

end
