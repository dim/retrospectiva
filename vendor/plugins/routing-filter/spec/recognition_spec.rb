require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'RoutingFilter', 'url recognition' do
  include RoutingFilterHelpers
  
  before :each do
    RoutingFilter::Locale.default_locale = :en
    I18n.default_locale = :en
    I18n.locale = :en

    @controller = instantiate_controller :locale => 'de', :id => 1
    @set = draw_routes do |map|
      map.filter 'locale'
      map.filter 'pagination'

      map.section 'sections/:id', :controller => 'sections', :action => "show"
      map.article 'sections/:section_id/articles/:id', :controller => 'articles', :action => "show"
    end
    
    @section_params = {:controller => 'sections', :action => "show", :id => "1"}
    @article_params = {:controller => 'articles', :action => "show", :section_id => "1", :id => "1"}
    @locale_filter = @set.filters.first
  end
  
  def should_recognize_path(path, params)
    @set.recognize_path(path, {}).should == params
  end
  
  def section_path(*args)
    @controller.send :section_path, *args
  end
  
  def url_for(*args)
    @controller.send :url_for, *args
  end

  it 'recognizes the path /de/sections/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1', @section_params.update(:locale => 'de')
  end
  
  it 'recognizes the path /sections/1/pages/1 and sets the :page param' do
    should_recognize_path '/sections/1/pages/1', @section_params.update(:page => 1)
  end

  it 'recognizes the path /de/sections/1/pages/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/pages/1', @section_params.update(:locale => 'de', :page => 1)
  end

  it 'recognizes the path /sections/1/articles/1 and sets the :locale param' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end

  it 'recognizes the path /de/sections/1/articles/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/articles/1', @article_params.update(:locale => 'de')
  end

  it 'recognizes the path /de/sections/1/articles/1/pages/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/articles/1/pages/1', @article_params.update(:locale => 'de', :page => 1)
  end
  
  it 'recognizes the path /sections/1 and does not set a :locale param' do
    should_recognize_path '/sections/1', @section_params
  end
  
  it 'recognizes the path /sections/1 and does not set a :page param' do
    should_recognize_path '/sections/1', @section_params
  end
  
  it 'recognizes the path /sections/1/articles/1 and does not set a :locale param' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end
  
  it 'recognizes the path /sections/1/articles/1 and does not set a :page param' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end
end