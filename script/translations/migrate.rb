#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/environment'

module RetroI18n

  mattr_accessor :old_translations
  self.old_translations = {}

  def self.define(locale, *args, &block)
    code = normalize_code(locale)
    self.old_translations[code] ||= Hash.new
    yield self.old_translations[code]
  end
  
  def self.tcode(string)
    string.gsub(/\%\w/, '').gsub(/\{\{\w+\}\}/, '').gsub(/^\([\w ]+\)/, '').gsub(/\W/, '').gsub(/_/, '').downcase
  end
  
end

Dir[RAILS_ROOT + '/lang/*.rb'].each {|f| load f }

RetroI18n.old_translations.each do |code, translations|
  next if translations.blank?
  
  patterns = RetroI18n::Parser.new(RAILS_ROOT + '/app/', RAILS_ROOT + '/lib/').patterns[:simple]
  file = RetroI18n::LocaleFile.new(RAILS_ROOT + "/locales/app.#{code}.yml")    

  sources = translations.inject({}) do |result, (key, value)|
    tcode = RetroI18n.tcode(key)
    tcode.blank? ? result : result.merge(tcode => [value].flatten.first)
  end

  patterns.each do |key, value|
    next if file.translations[key].present?
    
    tcode = RetroI18n.tcode(key)
    next if sources[tcode].blank?
    
    s_ph = sources[tcode].scan(/\%\w/)
    t_ph = key.scan(/\{\{\w+\}\}/)            
    next if s_ph.size != t_ph.size 
    
    sources[tcode].gsub!(/\%\w/) do |m|
      t_ph.shift
    end
    
    file.translations[key] = sources[tcode]
  end
  
  file.update(patterns)
end
