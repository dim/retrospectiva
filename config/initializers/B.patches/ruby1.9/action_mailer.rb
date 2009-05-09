module ActionMailer #:nodoc:
  class Base
    private

      def perform_delivery_smtp(mail)
        destinations = mail.destinations
        mail.ready_to_send
        sender = (mail['return-path'] && mail['return-path'].spec) || mail['from']

        smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
        smtp.enable_starttls_auto if smtp_settings[:enable_starttls_auto] && smtp.respond_to?(:enable_starttls_auto)
        smtp.start(smtp_settings[:domain], smtp_settings[:user_name], smtp_settings[:password],
                   smtp_settings[:authentication]) do |smtp|
          smtp.sendmail(mail.encoded, sender, destinations)
        end
      end

  end
end if RUBY_VERSION.to_f >= 1.9
