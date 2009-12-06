#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true

  validates_presence_of :content, :file_name, :content_type
  attr_accessor :content

  cattr_accessor :max_size
  self.max_size = 1024.kilobytes

  after_create   :write_file
  before_destroy :delete_file

  class << self

    def parse(stream)
      object = new(stream)
      object.ready_to_save? ? object : nil
    end

    def storage
      @@storage ||= HasAttachment::Storage::FileSystem.new(:path => Rails.root.join('attachments'))
    end

    def storage=(options = {})
      type = options.delete(:type).to_s.classify.to_sym
      @@storage = HasAttachment::Storage.const_get(type).new(options)
    end
    
    def reset_storage!
      @@storage = nil
    end

  end

  def initialize(stream)
    super(nil)
    if stream.respond_to?(:size) and stream.size.to_i > 0 and stream.respond_to?(:original_filename) && stream.respond_to?(:content_type)
      self.content = stream
      self.file_name = sanitize_filename(stream.original_filename)
      self.content_type = stream.content_type.to_s.strip
    end
  end
  
  def ready_to_save?
    new_record? and content.present?
  end
 
  def readable?
    @readable ||= storage.readable?(self)
  end
 
  def image?
    content_type.match(/^image\/(png|jpg|jpeg|gif)/i).present?
  end

  def html?
    content_type == Mime::HTML
  end    

  def plain?
    !html? and content_type.starts_with?('text/')
  end    

  def inline?
    html? || plain? || image?
  end
  
  def size
    if ready_to_save?
      content.size
    elsif readable?
      storage.size(self)
    else
      0
    end
  end

  def redirect?
    storage.redirect?
  end

  def redirect_url
    redirect? ? storage.url_for(self) : ''
  end

  def send_arguments
    redirect? ? [] : storage.send_arguments(self)
  end

  protected
    
    def storage
      self.class.storage
    end
  
    def write_file
      storage.write_file(self)  
    end  

    def delete_file
      storage.delete_file(self)  
    end

    def sanitize_filename(value)
      value.gsub(/^.*(\\|\/)/, '').gsub(/[^\w\.\-]/,'_')
    end
   
    def validate_on_create
      return true unless ready_to_save? # Skip if incomplete, let presence validations trigger instead   

      if content.size < 1
        errors.add :base, :invalid_file_size
      elsif content.size > self.class.max_size    
        errors.add :base, :file_size_exceeds_limit
      end
      
      storage.validate_on_create(self)      
      errors.empty?
    end

end
