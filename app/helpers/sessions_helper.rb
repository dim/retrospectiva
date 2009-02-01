module SessionsHelper

  def secure_auth?
    RetroCM[:general][:user_management][:secure_auth]  
  end
  
  def account_management?
    RetroCM[:general][:user_management][:account_management]  
  end

  def self_registration?
    RetroCM[:general][:user_management][:self_registration]  
  end  

  def secure_auth_tags
    if secure_auth?
      hidden_field_tag('user[tan]', SecureToken.generate(2.minutes), :id => 'user_tan') + 
      hidden_field_tag('user[hash]', '', :id => 'user_hash') + "\n"
    else
      ''
    end
  end

  def html_options_for_login_form
    if secure_auth?
      { :onsubmit => js_code_for_secure_auth } 
    else
      { }
    end.merge(:id => 'login_form')
  end

  private

    def js_code_for_secure_auth      
      %Q(
        username = $('user_username').value; 
        plain = $('user_password').value;
        tan   = $('user_tan').value;
        #{remote_function_for_secure_auth};
        hash = hex_sha1('+++{{' + plain + ':' + code + '}}---');
        $('user_hash').value = hex_sha1(tan + ':' + hash);
        $('user_password').value = '';
      ).strip.gsub(/\s+/m, ' ')
    end

    def remote_function_for_secure_auth
      remote_function(
        :url => secure_new_session_path, 
        :type => :synchronous, 
        :with => "'username=' + username", 
        :complete => 'code = request.responseText'
      )
    end
end
