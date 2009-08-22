ActionMailer::Base.class_eval do

  private
    
    def template_path
      File.join(template_root, mailer_name)
    end

end if Rails.version < '2.3.4'