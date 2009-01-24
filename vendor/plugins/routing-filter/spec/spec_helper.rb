$: << File.dirname(__FILE__)
$: << File.dirname(__FILE__) + '/../lib/'
$: << File.dirname(__FILE__) + '/../vendor/rails/actionpack/lib'
$: << File.dirname(__FILE__) + '/../vendor/rails/activesupport/lib'

require 'action_controller'
require 'action_controller/test_process'
require 'active_support/vendor'

require 'routing_filter'
require 'routing_filter/locale'
require 'routing_filter/pagination'

class Site
end

class Section
  def id; 1 end
  alias :to_param :id
  
  def type; 'Section' end
  
  def path; 'section' end
end

class Article
  def to_param; 1 end
end

module RoutingFilterHelpers
  def draw_routes(&block)
    set = returning ActionController::Routing::RouteSet.new do |set|
      class << set; def clear!; end; end
      set.draw &block
      silence_warnings{ ActionController::Routing.const_set 'Routes', set }
    end
    set
  end

  def instantiate_controller(params)
    returning ActionController::Base.new do |controller|
      request = ActionController::TestRequest.new
      url = ActionController::UrlRewriter.new(request, params)
      controller.stub!(:request).and_return request
      controller.instance_variable_set :@url, url
      controller
    end
  end
end