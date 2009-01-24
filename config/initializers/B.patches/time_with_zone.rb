#ActiveSupport::TimeWithZone.class_eval do    
#  alias_method :to_string, :to_s
#  
#  def rfc2822
#    to_string(:rfc822)
#  end
#  alias_method :rfc822, :rfc2822    
#
#  def w3cdtf
#    xmlschema
#  end
#
#  class << self
#    
#    def w3cdtf(date)
#      if /\A\s*
#          (-?\d+)-(\d\d)-(\d\d)
#          (?:T
#          (\d\d):(\d\d)(?::(\d\d))?
#          (\.\d+)?
#          (Z|[+-]\d\d:\d\d)?)?
#          \s*\z/ix =~ date and (($5 and $8) or (!$5 and !$8))
#        datetime = [$1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i]
#        usec = 0
#        usec = $7.to_f * 1000000 if $7
#        zone = $8
#        if zone
#          off = zone_offset(zone, datetime[0])
#          datetime = apply_offset(*(datetime + [off]))
#          datetime << usec
#          time = Time.utc(*datetime)
#          time.localtime unless zone_utc?(zone)
#          time
#        else
#          datetime << usec
#          Time.local(*datetime)
#        end
#      else
#        raise ArgumentError.new("invalid date: #{date.inspect}")
#      end
#    end
#  
#  end
#end
