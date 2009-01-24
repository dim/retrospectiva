module RetroI18n
  
  Locale = Struct.new(:code, :name, :priority)

  class LocaleDefinition < Array    

    def [](code)
      find {|i| i.code == code } || find {|i| i.code == I18n.default_locale } 
    end
    
    def store(*args)
      push RetroI18n::Locale.new(*args)
    end
    
  end

end
