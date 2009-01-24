# Copyright (c) 2006, Automatic Corp.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#   1. Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# 
#   2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
#   3. Neither the name of AUTOMATIC CORP. nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Patched by Dimitrij Denissenko, to support UTF-8 character encoding
#
module Enkoder

  def enkode( html, max_length=1024 )
    rnd = 10 + (rand*90).to_i

    kodes = [
      {
        'rb' => lambda do |s|
          s.reverse
        end,
        'js' => ";kode=kode.split('').reverse().join('')"
      },
      {
        'rb' => lambda do |s|
          result = ''
          s.each_byte { |b|
            b += 3
            b-=128 if b>127
            result += b.chr
          }
          result
        end,
        'js' => (
           ";x='';for(i=0;i<kode.length;i++){c=kode.charCodeAt(i)-3;" +
           "if(c<0)c+=128;x+=String.fromCharCode(c)}kode=x"
         )
      },
      {
        'rb' => lambda do |s|
          for i in (0..s.length/2-1)
            s[i*2],s[i*2+1] = s[i*2+1],s[i*2]
          end
          s
        end,
        'js' => (
           ";x='';for(i=0;i<(kode.length-1);i+=2){" +
           "x+=kode.charAt(i+1)+kode.charAt(i)}" +
           "kode=x+(i<kode.length?kode.charAt(kode.length-1):'');"
         )
      }
    ]

    kode = js_b64decode + " document.write(Base64.decode("+ js_dbl_quote(Base64.encode64(html)) +"));"
    max_length = kode.length+1 unless max_length>kode.length

    result = ''
    while kode.length < max_length
      idx = (rand*kodes.length).to_i
      kode = kodes[idx]['rb'].call(kode)
      kode = "kode=" + js_dbl_quote(kode) + kodes[idx]['js']
      js = "var kode=\n"+js_wrap_quote(js_dbl_quote(kode),79)
      js = js+"\n;var i,c,x;while(eval(kode));"
      js = "function hivelogic_enkoder(){"+js+"}hivelogic_enkoder();"
      js = '<script type="text/javascript">'+"\n/* <![CDATA[ */\n"+js
      js = js+"\n/* ]]> */\n</script>\n"
      result = js unless result.length>max_length
    end

    result
  end
      
  def enkode_mail( email, link_text, title_text=nil, subject=nil )
    str = String.new
    str << '<a href="mailto:' + email
    str << '?subject=' + subject unless subject.nil?
    str << '" title="'
    str << title_text unless title_text.nil?
    str << '">' + link_text + '</a>'
    enkode(str)
  end

  private

    # Taken from: http://www.webtoolkit.info/
    def js_b64decode
      "        
      var Base64 = {         
        _keyStr : 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=',
          
        decode : function (input) {
          var output = '';
          var chr1, chr2, chr3;
          var enc1, enc2, enc3, enc4;
          var i = 0;
          
          input = input.replace(/[^A-Za-z0-9\+\/\=]/g, '');
          
          while (i < input.length) {
            enc1 = this._keyStr.indexOf(input.charAt(i++));
            enc2 = this._keyStr.indexOf(input.charAt(i++));
            enc3 = this._keyStr.indexOf(input.charAt(i++));
            enc4 = this._keyStr.indexOf(input.charAt(i++));
      
            chr1 = (enc1 << 2) | (enc2 >> 4);
            chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
            chr3 = ((enc3 & 3) << 6) | enc4;
          
            output = output + String.fromCharCode(chr1);
      
            if (enc3 != 64) {
                output = output + String.fromCharCode(chr2);
            }
            if (enc4 != 64) {
                output = output + String.fromCharCode(chr3);
            }
          }
                  
          return Base64._utf8_decode(output);
        },
          
        _utf8_decode : function (utftext) {
          var string = '';
          var i = 0;
          var c = c1 = c2 = 0;
          
          while ( i < utftext.length ) {
            c = utftext.charCodeAt(i);
            if (c < 128) {
              string += String.fromCharCode(c);
              i++;
            }
            else if((c > 191) && (c < 224)) {
              c2 = utftext.charCodeAt(i+1);
              string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
              i += 2;
            }
            else {
              c2 = utftext.charCodeAt(i+1);
              c3 = utftext.charCodeAt(i+2);
              string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
              i += 3;
            }
          }
                  
          return string;
        }
      };        
      ".gsub(%r{[\n\r]}, ' ').gsub(%r{ +}, ' ')
    end
        
    def js_dbl_quote( str )
      str.inspect
    end

    def js_wrap_quote( str, max_line_length )
      max_line_length -= 3
      inQ = false
      esc = 0
      lineLen = 0
      result = ''
      chunk = ''
      while str.length > 0
        if str =~ /^\\[0-7]{3}/
          chunk = str[0..3]
          str[0..3] = ''
        elsif str =~ /^\\./
          chunk = str[0..1]
          str[0..1] = ''
        else
          chunk = str[0..0]
          str[0..0] = ''
        end
        if lineLen+chunk.length >= max_line_length
          result += '"+'+"\n"+'"'
          lineLen = 1
        end
        lineLen += chunk.length
        result += chunk;
      end
      result
    end

end
