module RoutingFilter
  class Base
    attr_accessor :successor, :options

    def initialize(options)
      @options = options
      options.each { |name, value| instance_variable_set :"@#{name}", value }
    end

    def run(method, *args, &block)
      successor = @successor ? lambda { @successor.run(method, *args, &block) } : block
      send method, *args, &successor
    end
  end
end