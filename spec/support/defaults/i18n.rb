module I18n
  class << self
  protected
    def raise_exceptions_on_missing_translations(exception, locale, key, options)
      raise exception if locale == default_locale
    end
  end
end
I18n.exception_handler = :raise_exceptions_on_missing_translations
