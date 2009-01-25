require 'has_attachment'
require_dependency 'attachment'

ActiveRecord::Base.class_eval do
  include HasAttachment
end