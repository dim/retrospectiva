module RetroI18n
  module Methods
  
    # Null-translation, just indicates that a string will be translated later, 
    # so the parser can pick it up 
    def N_(string)
      string
    end
  
    # Translate 
    def _(string, *args)
      options = args.extract_options!
      options.update(:default => string) if self.graceful || I18n.locale.to_sym == I18n.default_locale.to_sym
      I18n.t "application>>>#{string}", options
    end

    # Return the names map, as an array, useful for select tags. Example:
    #
    #   RetroI18n.choices # => [['English (US)', 'en-US'], ['Deutsch', 'de-DE'], ... ]
    #
    def choices(*only)
      only = only.map do |code|
        normalize_code(code)
      end
      
      locales.map do |locale|
        only.empty? || only.include?(locale.code) ? [ locale.name, locale.code ] : nil
      end.compact.sort_by(&:first)
    end
  
    # Example: RetroI18n.update('locales/de-DE.yml', 'app/', 'lib/')
    def update(target, *source_paths)
      patterns = Parser.new(*source_paths).patterns
      LocaleFile.new(target).update(patterns)
    end
  
    def define(&block)
      yield self.locales
    end
  
    def use_only(*codes)
      codes = codes.map do |code|
        normalize_code(code)
      end
  
      to_be_rejected = locales.map(&:code) - codes 
      self.locales.reject! do |locale|
        to_be_rejected.include?(locale.code)
      end
    end
  
    # Tries to guess the locale by parsing the given locale codes arguments. Examples:
    #
    #   RetroI18n.guess('en_GB') # => 'en-GB'
    #   RetroI18n.guess('en-GB') # => 'en-GB'
    #   RetroI18n.guess(:en_GB) # => 'en-GB'
    #   RetroI18n.guess('en', 'de') # => 'en-US'
    #   RetroI18n.guess('de', 'en') # => 'de-DE'
    #   RetroI18n.guess('invalid', 'missing', 'ja') # => 'ja-JP'
    def guess(*codes)
      available = locales.sort_by(&:priority).map(&:code)
      
      codes.flatten.each do |code|
        code  = normalize_code(code)
        match = available.find {|i| code == i } || 
          available.find {|i| code == i.split('-').first } ||
          available.find {|i| code == i.split('-').last }        
        return match if match
      end
      nil
    end
  
    def normalize_code(code)
      first, *others = code.to_s.split(/[^a-z]/i)      
      [first, *others.map(&:upcase)].join('-')
    end

  end
end
