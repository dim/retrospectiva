class Tan < ActiveRecord::Base
  cattr_accessor :default_expire_after 
  self.default_expire_after = 5.minutes

  validates_presence_of :value, :expires_at

  class << self
    def generate(expire_after = nil)    
      expires_at = Time.now.utc + (expire_after || default_expire_after)
      create(:expires_at => expires_at).value
    end
  
    def spend(value)
      delete_all_expired!
      record = find_by_value(value)
      record && record.destroy ? value : nil
    end

    def delete_all_expired!
      delete_all ['expires_at < ?', Time.now.utc]
    end    
  end
  
  protected

    def before_validation_on_create
      self.value = Digest::SHA1.hexdigest(Randomizer.string)      
      self.expires_at ||= (Time.now.utc + default_expire_after)
      true
    end

end
