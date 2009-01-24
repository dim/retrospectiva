require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'RoutingFilter' do
  include RoutingFilterHelpers

  before :each do
    @controller = instantiate_controller :locale => 'de', :section_id => 1
    @set = draw_routes do |map|
      map.section 'sections/:section_id', :controller => 'sections', :action => "show"
      map.filter 'locale'
      map.filter 'pagination'
    end
    @locale_filter = @set.filters.first
    @pagination_filter = @set.filters.last
  end
  
  def recognize_path(path = '/de/sections/1', options = {})
    @set.recognize_path path, options
  end
  
  def url_for(options)
    @controller.send :url_for, options
  end
  
  def section_path(*args)
    @controller.send :section_path, *args
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
    @locale_filter.should_receive(:around_generate).and_return '/sections/1'
    url_for :controller => 'sections', :action => 'show', :section_id => 1
  end

  it 'calls the second filter for url generation' do
    @pagination_filter.should_receive(:around_generate).and_return '/sections/1'
    url_for :controller => 'sections', :action => 'show', :section_id => 1
  end
  
  it 'calls the first filter for named route url_helper' do
    @locale_filter.should_receive(:around_generate).and_return '/sections/1'
    section_path :section_id => 1
  end
  
  it 'calls the filter for named route url_helper with "optimized" generation blocks' do
    @locale_filter.should_receive(:around_generate).and_return '/sections/1'
    section_path 1
  end
  
  it 'calls the filter for named route polymorphic_path' do
    @locale_filter.should_receive(:around_generate).and_return '/sections/1'
    section_path Section.new
  end
end