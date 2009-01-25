require 'has_attachment'
require 'attachment'

ActiveRecord::Base.class_eval do
  include HasAttachment
end