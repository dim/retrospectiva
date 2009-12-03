ActiveSupport::TimeWithZone.class_eval do    
  alias_method :to_string, :to_s  

  def rfc2822
    to_string(:rfc822)
  end
  alias_method :rfc822, :rfc2822    

  def w3cdtf
    xmlschema
  end

  def self.w3cdtf(date)
    Time.w3cdtf(date)
  end

end
