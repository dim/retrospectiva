require 'routing_filter/base'

module RoutingFilter
  class Pagination < Base
    def around_recognize(path, env, &block)
      path.gsub! %r(/pages/([\d]+)/?$), ''
      returning yield(path, env) do |params|
        params[:page] = $1.to_i if $1
      end
    end

    def around_generate(*args, &block)
      page = args.extract_options!.delete(:page)
      returning yield do |result|
        result.replace "#{result}/pages/#{page}" if page && page != 1
      end
    end
  end
end