class SecureToken < ActiveRecord::Base
  cattr_accessor :default_expire_after 
  self.default_expire_after = 5.minutes

  validates_presence_of :value, :expires_at

  class << self

    def prefix
      @prefix ||= name.demodulize.gsub(/[^A-Z]/, '')
    end

    def generate(expire_after = nil)    
      expires_at = Time.now.utc + (expire_after || default_expire_after)
      create(:expires_at => expires_at).to_s
    end
  
    def spend(token)
      purge_expired!     
      return nil unless token.to_s.match(/^#{prefix}-(\d+)-(\w+)$/)
      
      find_by_id_and_value($1.to_i, $2).tap do |record|
        record.destroy if record
      end
    end

    def purge_expired!
      with_exclusive_scope :find => {} do
        delete_all ['expires_at < ?', Time.now.utc]
      end
    end    
  
  end
  
  def to_s
    "#{self.class.prefix}-#{id}-#{value}"
  end
  
  protected

    def before_validation_on_create
      self.value = ActiveSupport::SecureRandom.hex(20)
      self.expires_at ||= Time.now.utc + default_expire_after
    end

end
