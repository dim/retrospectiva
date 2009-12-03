module ActionController
  module UrlWriter
    
    def self.reload!
      uri = URI.parse(RetroCM[:general][:basic][:site_url])
      options = { :protocol => uri.scheme, :host => uri.host }
      options.update(:port => uri.port) unless uri.port == uri.default_port
      
      included_in_classes.each do |klass|
        klass.default_url_options.update(options)
      end
    end
    
  end
end
