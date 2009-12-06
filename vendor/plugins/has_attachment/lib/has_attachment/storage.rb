module HasAttachment
  module Storage
    class Base      
      
      def initialize(options = {})        
      end
    
      def redirect?
        false
      end
    
      def validate_on_create(record)
      end

      def size(record)
        0
      end

    end
    
    class FileSystem < Base
      attr_reader :path

      def initialize(options = {})
        super
        @path = options[:path] || Rails.root.join('attachments')
      end
     
      def write_file(record)
        record.content.rewind
        File.open(physical_path(record), 'wb') {|f| f.write(record.content.read) }
      end

      def delete_file(record)
        if readable?(record)
          File.unlink(physical_path(record)) rescue false
        else
          true
        end
      end

      def readable?(record)
        File.readable?(physical_path(record))    
      end

      def send_arguments(record)
        options = {
          :filename => record.file_name,
          :type => record.plain? ? 'text/plain' : record.content_type,
          :disposition => ( record.inline? ? 'inline' : 'attachment' )
        }
        [ physical_path(record), options ]
      end
  
      def size(record)
        File.size(physical_path(record))
      end
 
      def physical_path(record)
        File.join(path, record.id.to_s)
      end

      def validate_on_create(record)
        unless File.directory?(path) && File.writable?(path)
          record.errors.add :base, :upload_not_permitted    
        end
      end

    end

    class S3 < Base
      attr_reader :bucket, :protocol, :use_ssl
      
      def initialize(options = {})
        require 'aws/s3'        
        super
        AWS::S3::Base.establish_connection!(
          :access_key_id => options[:access_key_id],
          :secret_access_key => options[:secret_access_key]
        )
        @bucket      = options[:bucket]
        @use_ssl     = options[:use_ssl] == true
      end

      def redirect?
        true
      end

      def url_for(record)
        AWS::S3::S3Object.url_for(record.id.to_s, bucket, :use_ssl => use_ssl, :expires_in => 60)
      end

      def readable?(record)
        AWS::S3::S3Object.exists?(record.id.to_s, bucket)
      end

      def write_file(record)
        record.content.rewind
        AWS::S3::S3Object.store record.id.to_s, record.content.read, bucket,
          :content_type => record.content_type
      end
      
      def delete_file(record)
        AWS::S3::S3Object.delete(record.id.to_s, bucket)
      rescue AWS::S3::ResponseError
      end

      def validate_on_create(record)
        unless AWS::S3::Base.connected?
          record.errors.add :base, :upload_not_permitted    
        end
      end

    end
  end
end
