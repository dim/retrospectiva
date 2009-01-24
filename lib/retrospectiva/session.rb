module Retrospectiva
  module Session
    mattr_accessor :secret_hash_path
    self.secret_hash_path = RAILS_ROOT + '/config/runtime/secret.hash'
    
    class << self
  
      def read_or_generate_secret
        from_file || new_secret
      end
    
      def from_file
        content = File.read(secret_hash_path) rescue ''
        content.blank? ? nil : content
      end
      private :from_file
  
      def new_secret
        require 'active_support/secure_random'
        secret = ActiveSupport::SecureRandom.hex(64)
        File.open(secret_hash_path, 'w') do |f|
          f.write secret
        end
        secret
      end
      private :new_secret
      
    end
  end    
end