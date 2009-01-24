module RoutingFilter
  mattr_accessor :active
  @@active = true
  
  class Chain < Array
    def << (filter)
      filter.successor = last
      super
    end
  
    def run(method, *args, &final)
      RoutingFilter.active && any? ? last.run(method, *args, &final) : final.call
    end
  end
end

# allows to install a filter to the route set by calling: map.filter 'locale'
ActionController::Routing::RouteSet::Mapper.class_eval do
  def filter(name, options = {})
    require "routing_filter/#{name}"
    klass = RoutingFilter.const_get name.to_s.camelize
    @set.filters << klass.new(options)
  end
end

# same here for the optimized url generation in named routes
ActionController::Routing::RouteSet::NamedRouteCollection.class_eval do
  # gosh. monkey engineering optimization code
  def generate_optimisation_block_with_filtering(*args)
    code = generate_optimisation_block_without_filtering(*args)
    code.gsub(/^return (.*) if (.*)$/) do |m|
      "return ActionController::Routing::Routes.filters.run(:around_generate, &lambda{ #{$1} }) if #{$2}"
    end
  end
  alias_method_chain :generate_optimisation_block, :filtering
end

ActionController::Routing::RouteSet.class_eval do
  def filters
    @filters ||= RoutingFilter::Chain.new
  end

  def recognize_path_with_filtering(path, env)
    path = path.dup # string is frozen due to memoize
    filters.run :around_recognize, path, env, &lambda{ recognize_path_without_filtering(path, env) }
  end
  alias_method_chain :recognize_path, :filtering
  
  def generate_with_filtering(*args)
    filters.run :around_generate, args.first, &lambda{ generate_without_filtering(*args) }
  end
  alias_method_chain :generate, :filtering

  # add some useful information to the request environment
  # right, this is from jamis buck's excellent article about routes internals
  # http://weblog.jamisbuck.org/2006/10/26/monkey-patching-rails-extending-routes-2
  # TODO move this ... where?
  alias_method :extract_request_environment_without_host, :extract_request_environment unless method_defined? :extract_request_environment_without_host
  def extract_request_environment(request)
    returning extract_request_environment_without_host(request) do |env|
      env.merge! :host => request.host,
                 :port => request.port,
                 :host_with_port => request.host_with_port,
                 :domain => request.domain,
                 :subdomain => request.subdomains.first
    end
  end
end