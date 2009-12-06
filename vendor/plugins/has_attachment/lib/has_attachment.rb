require 'attachment'
require 'has_attachment/storage'

module HasAttachment
  
  def self.included(base)
    base.extend ClassMethods 
  end
  
  module ClassMethods

    def has_attachment(options = {})
      has_one :attachment, options.merge(:as => :attachable)
      include InstanceMethods
      alias_method_chain :attachment=, :validation
    end

  end

  module InstanceMethods

    def attachment_with_validation=(value)
      self.attachment_without_validation = Attachment.parse(value)
    end
    
  end
  
end

ActiveRecord::Base.class_eval do
  include HasAttachment
end