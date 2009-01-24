#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true

  cattr_accessor :storage_path
  self.storage_path = File.join(RAILS_ROOT, 'attachments')

  validates_presence_of :content, :file_name, :content_type
  attr_accessor :content

  after_create   :write_file
  before_destroy :delete_file

  class << self

    def max_size
      RetroCM[:general][:attachments][:max_size]
    end

    def parse(stream)
      object = new(stream)
      object.ready_to_save? ? object : nil
    end

  end
   
  def initialize(stream)
    super(nil)
    if stream.respond_to?(:size) and stream.size.to_i > 0 and stream.respond_to?(:original_filename) && stream.respond_to?(:content_type)
      self.content = stream || ''
      self.file_name = sanitize_filename(stream.original_filename)
      self.content_type = stream.content_type.to_s.strip
    end
  end
  
  def ready_to_save?
    new_record? and content.present?
  end

  def read
    if ready_to_save?
      content.rewind
      content.read
    elsif readable?
      File.read(physical_path)
    else
      ''
    end
  end

  def readable?
    File.readable?(physical_path)    
  end
  
  def size
    if ready_to_save?
      content.size
    elsif readable?
      File.size(physical_path)
    else
      0
    end
  end
  
  def physical_path
    File.join(storage_path, id.to_s)
  end

  def image?
    content_type.match(/^image\/(png|jpg|jpeg|gif)/i).present?
  end

  def textual?
    content_type.match(/^text/i).present?
  end    

  def inline?
    textual? || image?
  end
  
  def send_arguments
    [physical_path, {
      :filename => file_name,
      :type => textual? ? 'text/plain' : content_type,
      :disposition => ( inline? ? 'inline' : 'attachment' )
    }]
  end
  
  protected
  
    def write_file
      File.open(physical_path, 'wb') {|f| content.rewind; f.write(content.read) }
    end  

    def delete_file
      if readable?
        File.unlink(physical_path) rescue false
      else
        true
      end
    end

    def sanitize_filename(value)
      value.gsub(/^.*(\\|\/)/, '').gsub(/[^\w\.\-]/,'_')
    end
   
    def validate_on_create
      return true unless ready_to_save? # Skip if incomplete, let presence validations trigger instead   

      if content.size < 1
        errors.add_to_base _('Invalid file size') 
      elsif content.size > self.class.max_size    
        errors.add_to_base _('File size exceeds the maximum limit')
      end
      
      unless File.directory?(storage_path) && File.writable?(storage_path)
        errors.add_to_base _('Upload is not permitted')    
      end
      
      errors.empty?
    end

end
