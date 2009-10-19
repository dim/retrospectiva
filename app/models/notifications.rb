##--
## Copyright (C) 2008 Dimitrij Denissenko
## Please read LICENSE document for more information.
##++
class Notifications < ActionMailer::Base
  helper NotificationsHelper
  include ActionController::UrlWriter

  class << self
    
    # Reloads SMTP server settings, allows dynamic configuration cahnges through Admin-Interface
    def reload_settings
      settings = RetroCM[:email][:smtp].settings.inject({}) do |result, setting|
        result.merge setting.name.to_sym => setting.value 
      end
      
      settings[:authentication] = settings[:authentication].to_sym      
      if settings[:authentication] == :none || settings[:user_name].blank? || settings[:password].blank?
        settings.merge!(:user_name => nil, :password => nil, :authentication => nil) 
      end
          
      ActionMailer::Base.smtp_settings = settings
    end

  end

  def account_activation_note(user, options = {})
    @subject    = options[:subject] || "[#{site_name}] " + _("Account activation")
    @body       = {:user => user, :site_name => site_name}
    @recipients = options[:recipients] || user.email
    @from       = options[:from] || from_address
    @sent_on    = options[:sent_on] || sent_on
    @headers    = {}
  end

  def account_validation(user, options = {})    
    @subject    = options[:subject] || "[#{site_name}] " + _("Account validation")
    @body       = {:user => user, :site_name => site_name}
    @recipients = options[:recipients] || user.email
    @from       = options[:from] || from_address
    @sent_on    = options[:sent_on] || sent_on
    @headers    = {}
  end

  def ticket_creation_note(ticket, options = {})    
    @subject    = options[:subject] || "[#{site_name}] #{ticket.previewable.title}"
    @body       = {:ticket => ticket}
    @recipients = options[:recipients]
    @from       = options[:from] || from_address
    @sent_on    = options[:sent_on] || sent_on
    @headers    = {}    
  end

  def ticket_update_note(ticket_change, options = {})    
    @subject    = options[:subject] || "[#{site_name}] #{ticket_change.previewable.title}"
    @body       = {:ticket_change => ticket_change}
    @recipients = options[:recipients]
    @from       = options[:from] || from_address
    @sent_on    = options[:sent_on] || sent_on
    @headers    = {}    
  end


  def password_reset_instructions(user, options = {})
    @subject    = options[:subject] || "[#{site_name}] " + _("Password reset")
    @body       = {:user => user, :site_name => site_name}
    @recipients = options[:recipients] || user.email
    @from       = options[:from] || from_address
    @sent_on    = options[:sent_on] || sent_on
    @headers    = {}
  end

  private
      
    def sent_on
      Time.now      
    end
      
    def from_address
      RetroCM[:email][:general][:from]
    end
  
    def site_name
      RetroCM[:general][:basic][:site_name]
    end        

end