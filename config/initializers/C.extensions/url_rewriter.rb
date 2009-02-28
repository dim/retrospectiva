module ActionController
  module UrlWriter

    # Always delegate the default_url_options (instead of assigning them) 
    def self.included(base) #:nodoc:
      ActionController::Routing::Routes.install_helpers(base)
      base.class.delegate :default_url_options, :to => :'ActionController::UrlWriter'
    end
    
    def self.reload!
      uri = URI.parse(RetroCM[:general][:basic][:site_url])
      default_url_options.merge!(:protocol => uri.scheme, :host => uri.host)
      default_url_options.merge!(:port => uri.port) unless uri.port == uri.default_port
      default_url_options
    end
  end
end
