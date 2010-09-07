require 'wiki_engine/engines'

module WikiEngine
  @@default_engine = nil

  mattr_accessor :supported_engines
  self.supported_engines = {'retro' => nil, 'rdoc' => nil, 'textile' => nil, 'markdown' => nil}

  class << self

    # Returns an array of system available WIKI engines
    # eg. ['retro', 'rdoc', 'textile', 'markdown']
    def supported_engine_names
      supported_engines.map {|k, v| v ? k : nil }.compact
    end

    # Returns the HTML formatted markup
    def markup(text, engine = nil)
      engine = select_engine(engine)
      text.blank? ? '' : engine.markup(text)
    end
  
    # This method can be called in environment.rb to override the default engine
    def default_engine=(engine)
      engine = engine.to_s
      if !supported_engines.include?(engine)
        raise "The selected WIKI engine '#{engine}' is invalid! Supported engines: #{supported_engines.keys.inspect}"
      elsif supported_engines[engine]
        @@default_engine = supported_engines[engine]
      elsif supported_engines.values.compact.any?
        @@default_engine = supported_engines.values.first
      else
        raise "The selected WIKI default engine '#{engine}' is missing! " + 
              "Please install required GEM or library or switch to another engine. " + 
              "Supported engines: #{supported_engine_names.inspect}" 
      end
    end

    # Returns the default engine
    def default_engine
      @@default_engine ? @@default_engine : supported_engines['retro']
    end

    # Initializes the WikiEngine. Looks for available libraries. A default engine can be specified.
    def init(default = :retro)
      begin
        require 'wiki_engine/redcloth'
        self.supported_engines['textile'] = TextileEngine.new
        require 'wiki_engine/retro'
        self.supported_engines['retro'] = RetroEngine.new
      rescue LoadError; end
      
      begin
        require 'rdiscount'
        self.supported_engines['markdown'] = MarkDownEngine.new
      rescue LoadError; end
      
      begin
        require 'rdoc/markup/simple_markup'
        require 'rdoc/markup/simple_markup/to_html'
        require 'wiki_engine/rdoc'
        self.supported_engines['rdoc'] = RDocEngine.new
      rescue LoadError; end
      
      self.default_engine = default
    end

    def with_text_parts_only(text, &block)
      tokenizer = HTML::Tokenizer.new(text)
      open_pre  = false
      
      [].tap do |result|           
        
        while token = tokenizer.next
          node = HTML::Node.parse(nil, 0, 0, token, false)
          
          if !open_pre and node.is_a?(HTML::Text)
            result << yield(token)
          else
            if node.is_a?(HTML::Tag) and node.name == 'pre'
              open_pre = node.closing.nil? 
            end
            result << token
          end
        end

      end.join      
    end    

    private      

      def select_engine(engine = nil)
        engine && supported_engines[engine] ? supported_engines[engine] : default_engine        
      end
    
  end
end
