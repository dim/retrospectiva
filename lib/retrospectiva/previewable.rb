require 'rss/maker'
require 'retrospectiva/previewable/base'
require 'retrospectiva/previewable/entities'
require 'retrospectiva/previewable/extension'

ActiveRecord::Base.class_eval do
  include Retrospectiva::Previewable::Extension
end

ActiveSupport::Dependencies.load_paths.map do |path|
  Dir[path + '/**/*.rb']
end.flatten.uniq.each do |file|
  content = File.read(file)
  ActiveSupport::Dependencies.depend_on(file) if content =~ /retro_previewable\s+(do|\{)/
end unless $rails_gem_installer

