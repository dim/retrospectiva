# coding:utf-8 

require 'retro_i18n/patches'
require 'retro_i18n/parser'
require 'retro_i18n/locale_file'
require 'retro_i18n/structs'
require 'retro_i18n/methods'
require 'retro_i18n/ya2yaml'

Dir[File.dirname(__FILE__) + '/../locales/*.{rb,yml}'].each do |path|
  I18n.load_path << path
end

module RetroI18n
  mattr_accessor :locales
  self.locales = LocaleDefinition.new

  mattr_accessor :graceful
  self.graceful = true

  extend Methods
end

RetroI18n.define do |l|  
  l.store 'cs-CZ',     'Česky', 0 
  l.store 'da-DK',     'Dansk', 0 
  l.store 'de-DE',     'Deutsch', 0 
  l.store 'en-US',     'English (US)', 0 
  l.store 'en-GB',     'English (GB)', 1
  l.store 'fr-FR',     'Français', 0
  l.store 'fi-FI',     'Suomi', 0  
  l.store 'es-ES',     'Español', 0
  l.store 'es-AR',     'Español (de Argentina)', 0
  l.store 'it-IT',     'Italiano', 0
  l.store 'ja-JP',     '日本語 (Japanese)', 0
  l.store 'nl-NL',     'Nederlands', 0
  l.store 'nb-NO',     'Norsk', 0
  l.store 'ru-RU',     'Русский', 0
  l.store 'pt-BR',     'Português Brasileiro', 0
  l.store 'sv-SE',     'Svenska', 0
end
