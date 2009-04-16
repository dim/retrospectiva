# coding:utf-8 
#
# RFC822 Email Address Regex
# --------------------------
# 
# Originally written by Cal Henderson
# c.f. http://iamcal.com/publish/articles/php/parsing_email/
#
# Translated to Ruby by Tim Fletcher, with changes suggested by Dan Kubb.
#
# Licensed under a Creative Commons Attribution-ShareAlike 2.5 License
# http://creativecommons.org/licenses/by-sa/2.5/
# 
module RFC822
  
  module Patterns
    
    def self.compile(string)
      Regexp.new string, nil, 'n'
    end
    
    QTEXT     = compile "[^\\x0d\\x22\\x5c\\x80-\\xff]"  
    DTEXT     = compile "[^\\x0d\\x5b-\\x5d\\x80-\\xff]" 
    
    ATOM_CORE = compile "[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+"
    ATOM_EDGE = compile "[^\\x00-\\x20\\x22\\x28\\x29\\x2c-\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]"
    ATOM      = compile "(?:#{ATOM_EDGE}{1,2}|#{ATOM_EDGE}#{ATOM_CORE}#{ATOM_EDGE})"
    
    QPAIR     = compile "\\x5c[\\x00-\\x7f]"
    QSTRING   = compile "\\x22(?:#{QTEXT}|#{QPAIR})*\\x22"
    
    WORD      = compile "(?:#{ATOM}|#{QSTRING})"

    DOMAIN_PT = compile "(?:[a-zA-Z0-9][\-a-zA-Z0-9]*[a-zA-Z0-9]|[a-zA-Z0-9]+)"

    DOMAIN    = compile "#{DOMAIN_PT}(?:\\x2e#{DOMAIN_PT})*"
    LOCAL_PT  = compile "#{WORD}(?:\\x2e#{WORD})*"
    ADDRESS   = compile "#{LOCAL_PT}\\x40#{DOMAIN}"    
  
  end
  
  EmailAddress = /\A#{Patterns::ADDRESS}\z/

end

# Validation helper for ActiveRecord derived objects that cleanly and simply
# allows the model to check if the given string is a syntactically valid email
# address (by using the RFC822 module above).
#
# Original code by Ximon Eighteen <ximon.eightee@int.greenpeace.org> which was
# heavily based on code I can no longer find on the net, my apologies to the
# author!
#
# Huge credit goes to Dan Kubb <dan.kubb@autopilotmarketing.com> for
# submitting a patch to massively simplify this code and thereby instruct me
# in the ways of Rails too! I reflowed the patch a little to keep the line
# length to a maximum of 78 characters, an old habit.

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_as_email(*attr_names)
        configuration = {
          :message   => 'is an invalid email',
          :with      => RFC822::EmailAddress,
          :allow_nil => true }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        validates_format_of attr_names, configuration
      end
    end
  end
end
