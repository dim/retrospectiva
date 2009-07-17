module RetroI18n  
  class LocaleFile
    attr_reader :path
    
    LOCALE = /[a-z]{2}-[A-Z]{2}/
    
    def initialize(path)
      @path = path
    end
    
    def locale
      @locale ||= ( File.basename(path, '.yml').match(LOCALE)[0] rescue 'en-US' )
    end
    
    def update(patterns)
      translations.each do |string,|
        patterns[string] ||= []
      end
      save(patterns)
    end
    
    def save(patterns, options = {})
      yaml = Ya2YAML.new :syck_compatible => true    
      
      File.open(path, 'w+') do |file|
        file << "#{locale}:\n  application:\n"
        
        patterns.sort_by(&:first).each do |string, references|
          if options[:comments] == false
          elsif references.blank?
            file << "    # Unknown\n"
          else
            file << "    # Missing\n" if t(string).blank?
            references.uniq.sort.each do |reference|
              file << "    # #{reference}\n"
            end
          end          
          file << "    #{yaml.emit_string(string, 3)}: #{t(string).blank? ? nil : yaml.emit_string(t(string), 3)}\n\n"
        end
      end && true
    end

    def translations
      @translations ||= load_translations
    end

    def t(string)
      translations[string]
    end
    
    protected
      
      def load_translations
        (YAML.load_file(path)[locale]['application'] || {}) rescue {}
      end

  end  
end