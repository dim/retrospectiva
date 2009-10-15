I18n.default_locale = :'en-US'
I18n.locale = :'en-US'

Dir[RAILS_ROOT + '/locales/**/*.{rb,yml}'].uniq.each do |locale_file|
  I18n.load_path << locale_file
end
RetroI18n.use_only 'de-DE', 'en-US', 'en-GB', 'es-AR', 'es-ES', 'fr-FR', 'ja-JP', 'pt-BR', 'ru-RU'
