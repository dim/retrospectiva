require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'RoutingFilter' do
  include RoutingFilterHelpers

  before :each do
    setup_environment :locale, :pagination
  end

  def recognize_path(path = '/de/sections/1', options = {})
    @set.recognize_path path, options
  end

  it 'installs filters to the route set' do
    @locale_filter.should be_instance_of(RoutingFilter::Locale)
    @pagination_filter.should be_instance_of(RoutingFilter::Pagination)
  end

  it 'calls the first filter for route recognition' do
    @locale_filter.should_receive(:around_recognize).and_return :foo => :bar
    recognize_path.should == {:foo => :bar}
  end

  it 'calls the second filter for route recognition' do
    @pagination_filter.should_receive(:around_recognize).and_return :foo => :bar
    recognize_path.should == {:foo => :bar}
  end

  it 'calls the first filter for url generation' do
    @locale_filter.should_receive(:around_generate).and_return '/en/sections/1'
    url_for :controller => 'sections', :action => 'show', :section_id => 1
  end

  it 'calls the second filter for url generation' do
    @pagination_filter.should_receive(:around_generate).and_return '/en/sections/1'
    url_for :controller => 'sections', :action => 'show', :section_id => 1
  end

  it 'calls the first filter for named route url_helper' do
    @locale_filter.should_receive(:around_generate).and_return '/en/sections/1'
    section_path :section_id => 1
  end

  it 'calls the filter for named route url_helper with "optimized" generation blocks' do
    # at_least(1) since the inline code comments in ActionController::Routing::RouteSet::NamedRouteCollection#define_url_helper also call us (as of http://github.com/rails/rails/commit/a2270ef2594b97891994848138614657363f2806)
    @locale_filter.should_receive(:around_generate).at_least(1).and_return '/en/sections/1'
    section_path 1
  end

  it 'calls the filter for named route polymorphic_path' do
    # at_least(1) since the inline code comments in ActionController::Routing::RouteSet::NamedRouteCollection#define_url_helper also call us (as of http://github.com/rails/rails/commit/a2270ef2594b97891994848138614657363f2806)
    @locale_filter.should_receive(:around_generate).at_least(1).and_return '/en/sections/1'
    section_path Section.new
  end
end