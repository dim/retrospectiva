require 'wiki_engine/engines'

module WikiEngine
  @@default_engine = nil

  mattr_accessor :supported_engines
  self.supported_engines = {'retro' => nil, 'rdoc' => nil, 'textile' => nil, 'markdown' => nil}

  class << self

    # Returns an array of system available WIKI engines
    # eg. ['retro', 'rdoc', 'textile', 'markdown']
    def supported_engine_names
      supported_engines.map { |(k, v)| v ? k : nil }.compact
    end
    alias_method :available_engine_names, :supported_engine_names

    def default
      supported_engines[default_engine]
    end

    # Returns the HTML formatted markup
    def markup(text, engine = nil)
      engine = select_engine(engine)
      text.blank? || engine.blank? ? '' : supported_engines[engine].markup(text)
    end
  
    def link_all(text, engine = nil, &block)
      engine = select_engine(engine)
      text.blank? || engine.blank? ? '' : supported_engines[engine].link_all(text, &block)
    end

    def link_pattern(engine = nil)
      engine = select_engine(engine)
      engine.blank? ? %r{} : supported_engines[engine].link_pattern
    end

    # This method can be called in environment.rb to override the default engine
    def default_engine=(engine)
      engine = engine.to_s
      if !self.supported_engines.include?(engine)
        raise "The selected WIKI engine '#{engine}' is invalid! Supported engines: #{supported_engines.keys.inspect}"
      elsif supported_engines[engine]
        @@default_engine = engine
      elsif supported_engines.values.compact.any?
        @@default_engine = supported_engines.values.first
      else
        raise "The selected WIKI default engine '#{engine}' is missing! " + 
              "Please install required GEM or library or switch to another engine. " + 
              "Available engines: #{available_engine_names.inspect}" 
      end
    end
    alias_method :default_markup=, :default_engine=

    # Returns the default engine
    def default_engine
      @@default_engine ? @@default_engine : 'retro'
    end
    alias_method :default_markup, :default_engine

    # Initializes the WikiEngine. Looks for available libraries. A default engine can be specified.
    def init(default = :retro)
      begin
        require 'redcloth'
        self.supported_engines['textile'] = TextileEngine.new
        require 'wiki_engine/retro'
        self.supported_engines['retro'] = RetroEngine.new
      rescue LoadError; end
      
      begin
        require 'bluecloth'
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
      result, tokenizer = [], HTML::Tokenizer.new(text.gsub(/<pre[^>]*>.+?<\/pre[^>]*>/im, ''))
      while token = tokenizer.next        
        node = parse_node(token)
        result << yield(token) if node.is_a?(HTML::Text)
      end
      result.join      
    end    

    private

      def parse_node(token)
        HTML::Node.parse(nil, 0, 0, token, false)
      end

      def select_engine(engine = nil)
        engine && supported_engines[engine] ? engine : default_engine        
      end
    
  end
end
