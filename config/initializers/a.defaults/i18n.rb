I18n.default_locale = :'en-US'
I18n.locale = :'en-US'

I18n::Backend::Simple.class_eval do
  protected

    def init_translations_with_normalization
      init_translations_without_normalization.tap do
        translations[I18n.default_locale] ||= {}
        translations[I18n.default_locale].deep_merge!(translations[:en])
      end
    end 
    alias_method_chain :init_translations, :normalization
end


Dir[RAILS_ROOT + '/locales/**/*.{rb,yml}'].uniq.each do |locale_file|
  I18n.load_path << locale_file
end
RetroI18n.use_only 'cs-CZ', 'de-DE', 'en-US', 'en-GB', 'es-AR', 'es-ES', 'fr-FR', 'ja-JP', 'pt-BR', 'ru-RU'
RetroI18n.graceful = Rails.env.production?
