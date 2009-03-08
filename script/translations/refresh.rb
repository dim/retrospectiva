#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/environment'
require File.dirname(__FILE__) + '/retro_i18n/settings_file'

I18n.backend.send :init_translations

#
# Refresh all existing Core-Application translations
#
RetroI18n.locales.map(&:code).each do |locale|
  next if locale == 'en-US'

  file = RAILS_ROOT + "/locales/app/#{locale}.yml"
  RetroI18n.update(file, RAILS_ROOT + '/app/', RAILS_ROOT + '/lib/', RAILS_ROOT + '/vendor/')
end  

#
# Refresh all existing Core-Settings translations
#
RetroI18n.locales.map(&:code).each do |locale|
  next if locale == 'en-US'

  file = RAILS_ROOT + "/locales/settings/#{locale}.yml"
  settings = RetroI18n::SettingsFile.new(file)
  settings.update
end  

#
# Refresh all existing Extension-Application translations
#
Dir[RAILS_ROOT + '/extensions/*/locales/app/'].each do |locales_path|
  extension_path = locales_path.gsub(/\/locales\/.*$/, '')

  # Parse all translations from the extensions/extension_name directory 
  patterns = RetroI18n::Parser.new(extension_path).patterns[:simple]

  RetroI18n.locales.map(&:code).each do |locale|
    next if locale == 'en-US'
    
    file_path = "#{locales_path}/#{locale}.yml"  
        
    # Load and update all existing Extension translations  
    target   = RetroI18n::LocaleFile.new(file_path)  
    target.update(patterns.dup)
    
    # Load all existing Core translations  
    source_path = file_path.gsub(/\/extensions\/.+?\//, '/')
    source = RetroI18n::LocaleFile.new(source_path)
    
#    if File.exist?(source.path)
#  
#      # If Extension has untranslated patterns that were already translated
#      # in the Core, use them!
#      target.translations.each do |key, value|
#        next if value.present? or source.translations[key].blank?
#        target.translations[key] = source.translations[key]         
#      end 
#      
#      # Load and update all existing Extension translations  
#      target.update(patterns)  
#    end

  end
end  
