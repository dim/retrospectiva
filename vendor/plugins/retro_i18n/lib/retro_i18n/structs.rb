module RetroI18n
  
  Locale = Struct.new(:code, :name, :priority)

  class LocaleDefinition < Array    

    def find(code)
      code = RetroI18n.normalize_code(code)
      detect {|i| i.code == code } || default  
    end
    alias_method :[], :find
    
    def store(code, name, priority)
      push RetroI18n::Locale.new(RetroI18n.normalize_code(code), name, priority)
    end

    def default
      detect {|i| i.code == RetroI18n.normalize_code(I18n.default_locale) }
    end
    
  end

end
