module ActionController
  module UrlWriter
    # Always use the same default_url_options 
    def self.included(base) #:nodoc:
      ActionController::Routing::Routes.install_helpers(base)
      base.class_eval do
        def self.default_url_options
          ActionController::UrlWriter.default_url_options
        end
      end
    end
    
    def self.reload!
      uri = URI.parse(RetroCM[:general][:basic][:site_url])
      default_url_options.merge!(:protocol => uri.scheme, :host => uri.host)
      default_url_options.merge!(:port => uri.port) unless uri.port == uri.default_port
      default_url_options
    end
  end
end
