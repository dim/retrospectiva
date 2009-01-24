require 'i18n'
require 'routing_filter/base'

module RoutingFilter
  class Locale < Base
    @@default_locale = :en
    cattr_reader :default_locale
    
    class << self
      def default_locale=(locale)
        @@default_locale = locale.to_sym
      end
    end
    
    # remove the locale from the beginning of the path, pass the path
    # to the given block and set it to the resulting params hash
    def around_recognize(path, env, &block)
      locale = nil
      path.sub! %r(^/([a-zA-Z]{2})(?=/|$)) do locale = $1; '' end
      returning yield do |params|
        params[:locale] = locale if locale
      end
    end
    
    def around_generate(*args, &block)
      locale = args.extract_options!.delete(:locale) || I18n.locale
      returning yield do |result|
        if locale.to_sym != @@default_locale
          result.sub!(%r(^(http.?://[^/]*)?(.*))){ "#{$1}/#{locale}#{$2}" }
        end 
      end
    end
  end
end