require 'has_attachment'

ActiveRecord::Base.class_eval do
  include HasAttachment
end