## Override rails' default AUTO_LINK_RE to fix a bug
#AUTO_LINK_RE = %r{
#  (                          # leading text
#    <\w+.*?>|                # leading HTML tag, or
#    [^=!:'"/]|               # leading punctuation, or 
#    ^                        # beginning of line
#  )
#  (
#    (?:https?://)|           # protocol spec, or
#    (?:www\.)                # www.*
#  ) 
#  (
#    [-\w]+                   # subdomain or domain
#    (?:\.[-\w]+)*            # remaining subdomains or domain
#    (?::\d+)?                # port
#    (?:/(?:[~\w\+@%=\(\)-]|(?:[,.;:'][^\s<$]))*)* # path
#    (?:\?[\w\+@%&=.;:-]+)?   # query string
#    (?:\#[\w\-]*)?           # trailing anchor
#  )
#  ([[:punct:]]|<|$|)         # trailing text
#}x
#
#
