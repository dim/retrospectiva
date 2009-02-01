require 'rss/maker'
require 'retrospectiva/previewable/base'
require 'retrospectiva/previewable/entities'
require 'retrospectiva/previewable/extension'

ActiveRecord::Base.class_eval do
  include Retrospectiva::Previewable::Extension
end