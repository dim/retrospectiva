Attachment.class_eval do
  class << self
    def max_size
      RetroCM[:general][:attachments][:max_size].to_i.kilobytes
    end
  end
end  