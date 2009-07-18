#!/usr/bin/env ruby

# Run in test mode for safety reasons and to prevent extensions from being loaded
ENV["RAILS_ENV"] ||= 'test'

require File.dirname(__FILE__) + '/../../config/environment'
require File.dirname(__FILE__) + '/retro_i18n/settings_file'

I18n.backend.send :init_translations

#
# Refresh all existing Core-Application translations
#
RetroI18n.locales.map(&:code).each do |locale|
  next if locale == 'en-US'

  file = RAILS_ROOT + "/locales/app/#{locale}.yml"
  RetroI18n.update file, RAILS_ROOT + '/app/**/*.{rb,erb,rjs}', RAILS_ROOT + '/lib/**/*.rb', RAILS_ROOT + '/vendor/plugins/**/*.rb'
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

  RetroI18n.locales.map(&:code).each do |locale|
    next if locale == 'en-US'
    
    file_path = "#{locales_path}/#{locale}.yml"  
        
    # Parse all translations from the extensions/extension_name directory 
    patterns = RetroI18n::Parser.new(extension_path + '/**/*.{rb,erb,rjs}').patterns

    # Load and update all existing Extension translations  
    target   = RetroI18n::LocaleFile.new(file_path)  
    target.update(patterns)
    
    # Load all existing Core translations  
    source_path = file_path.gsub(/\/extensions\/.+?\//, '/')
    source = RetroI18n::LocaleFile.new(source_path)
    
    if File.exist?(source.path)  
      # If Extension has untranslated patterns that were already translated
      # in the Core, use them!
      target.translations.each do |key, value|
        next if value.present? or source.translations[key].blank?
        target.translations[key] = source.translations[key]         
      end 
      
      # Load and update all existing Extension translations  
      target.update(patterns)  
    end

  end
end  
