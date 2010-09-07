require 'i18n'

I18n.module_eval do
  class << self
      
    def normalize_keys(locale, key, scope, separator = nil)
      separator ||= key.to_s =~ /\>\>\>/ ?  /\>\>\>/ : /\./
      keys = [locale] + Array(scope) + Array(key)
      keys = keys.map { |k| k.to_s.split(separator) }
      keys = keys.flatten - ['']
      keys.map { |k| k.to_sym }
    end

  end
end

class Object
  def N_(*args); RetroI18n.N_(*args); end
  def _(*args); RetroI18n._(*args); end
end
