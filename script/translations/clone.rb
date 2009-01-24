#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/environment'

file = RetroI18n::LocaleFile.new(RAILS_ROOT + "/locales/app.#{ARGV.first.to_s}.yml")
exit(1) unless File.exist?(file.path)

patterns = RetroI18n::Parser.new(RAILS_ROOT + '/app/', RAILS_ROOT + '/lib/').patterns[:simple]
patterns.each do |pattern,|
  next if file.translations[pattern].present?
  file.translations[pattern] = pattern
end

file.update(patterns)
