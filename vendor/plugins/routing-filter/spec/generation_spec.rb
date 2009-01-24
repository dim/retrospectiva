require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'RoutingFilter', 'url generation' do
  include RoutingFilterHelpers

  before :each do
    RoutingFilter::Locale.default_locale = :en
    I18n.default_locale = :en
    I18n.locale = :en

    @controller = instantiate_controller :locale => 'de', :id => 1
    @set = draw_routes do |map|
      map.section 'sections/:id', :controller => 'sections', :action => "show"
      map.section_article 'sections/:section_id/articles/:id', :controller => 'articles', :action => "show"
      
      map.filter 'locale'
      map.filter 'pagination'
    end
    
    @site = Site.new
    @section = Section.new
    @article = Article.new

    @params = {:controller => 'sections', :action => "show", :id => "1"}
    @article_params = {:controller => 'articles', :action => 'show', :section_id => "1", :id => "1"}
    @locale_filter = @set.filters.first
    
    Section.stub!(:types).and_return ['Section']
    Section.stub!(:find).and_return @section
  end

  def should_recognize_path(path, params)
    @set.recognize_path(path, {}).should == params
  end

  def section_path(*args)
    @controller.send :section_path, *args
  end

  def section_article_path(*args)
    @controller.send :section_article_path, *args
  end

  def url_for(*args)
    @controller.send :url_for, *args
  end
  
  describe "named route url_helpers" do
    describe "a not nested resource" do
      it 'does not change the section_path when the current locale is the default locale and no page option given' do
        section_path(:id => 1).should == '/sections/1'
      end
  
      it 'does not change the section_path when given page option equals 1' do
        section_path(:id => 1, :page => 1).should == '/sections/1'
      end
  
      it 'appends the pages segments to section_path when given page option does not equal 1' do
        section_path(:id => 1, :page => 2).should == '/sections/1/pages/2'
      end
  
      it 'prepends the current locale to section_path when it is not the default locale' do
        I18n.locale = :de
        section_path(:id => 1).should == '/de/sections/1'
      end
  
      it 'prepends a given locale param to section_path when it is not the default locale' do
        I18n.locale = :de
        section_path(:id => 1, :locale => :fi).should == '/fi/sections/1'
      end
  
      it 'works on section_path with both a locale and page option' do
        section_path(:id => 1, :locale => :fi, :page => 2).should == '/fi/sections/1/pages/2'
      end
    end
    
    describe "a nested resource" do
      it 'does not change the section_article_path when the current locale is the default locale and no page option given' do
        section_article_path(:section_id => 1, :id => 1).should == '/sections/1/articles/1'
      end
  
      it 'does not change the section_article_path when given page option equals 1' do
        section_article_path(:section_id => 1, :id => 1, :page => 1).should == '/sections/1/articles/1'
      end
    
      it 'appends the pages segments to section_article_path when given page option does not equal 1' do
        section_article_path(:section_id => 1, :id => 1, :page => 2).should == '/sections/1/articles/1/pages/2'
      end
    
      it 'prepends the current locale to section_article_path when it is not the default locale' do
        I18n.locale = :de
        section_article_path(:section_id => 1, :id => 1).should == '/de/sections/1/articles/1'
      end
    
      it 'prepends a given locale param to section_article_path when it is not the default locale' do
        I18n.locale = :de
        section_article_path(:section_id => 1, :id => 1, :locale => :fi).should == '/fi/sections/1/articles/1'
      end
    
      it 'works on section_article_path with both a locale and page option' do
        section_article_path(:section_id => 1, :id => 1, :locale => :fi, :page => 2).should == '/fi/sections/1/articles/1/pages/2'
      end
    end
  end
  
  describe 'when used with named route url_helper with "optimized" generation blocks' do
    describe "a not nested resource" do
      # uses optimization
      it 'does not change the section_path when the current locale is the default locale and no page option given' do
        section_path(1).should == '/sections/1'
      end
  
      # uses optimization
      it 'prepends the current locale to section_path when it is not the default locale' do
        I18n.locale = :de
        section_path(1).should == '/de/sections/1'
      end
  
      it 'prepends a given locale param to section_path when it is not the default locale' do
        I18n.locale = :de
        section_path(1, :locale => :fi).should == '/fi/sections/1'
      end
    
      it 'does not change the section_path when given page option equals 1' do
        section_path(1, :page => 1).should == '/sections/1'
      end
  
      it 'appends the pages segments to section_path when given page option does not equal 1' do
        section_path(1, :page => 2).should == '/sections/1/pages/2'
      end
  
      it 'works for section_path with both a locale and page option' do
        section_path(1, :locale => :fi, :page => 2).should == '/fi/sections/1/pages/2'
      end
    end
  
    describe "a nested resource" do
      # uses optimization
      it 'does not change the section_article_path when the current locale is the default locale and no page option given' do
        section_article_path(1, 1).should == '/sections/1/articles/1'
      end
  
      # uses optimization
      it 'prepends the current locale to section_article_path when it is not the default locale' do
        I18n.locale = :de
        section_article_path(1, 1).should == '/de/sections/1/articles/1'
      end
  
      it 'prepends a given locale param when it is not the default locale' do
        I18n.locale = :de
        section_article_path(1, 1, :locale => :fi).should == '/fi/sections/1/articles/1'
      end
    
      it 'does not change the section_article_path when given page option equals 1' do
        section_article_path(1, 1, :page => 1).should == '/sections/1/articles/1'
      end
  
      it 'appends the pages segments to section_article_path when given page option does not equal 1' do
        section_article_path(1, 1, :page => 2).should == '/sections/1/articles/1/pages/2'
      end
  
      it 'works for section_article_path with both a locale and page option' do
        section_article_path(1, 1, :locale => :fi, :page => 2).should == '/fi/sections/1/articles/1/pages/2'
      end
    end
  end
  
  describe 'when used with a polymorphic_path' do
    describe "a not nested resource" do
      # uses optimization
      it 'does not change the section_path when the current locale is the default locale and no page option given' do
        section_path(@section).should == '/sections/1'
      end
  
      # uses optimization
      it 'prepends the current locale to section_path when it is not the default locale' do
        I18n.locale = :de
        section_path(@section).should == '/de/sections/1'
      end
  
      it 'prepends a given locale param to section_path when it is not the default locale' do
        I18n.locale = :de
        section_path(@section, :locale => :fi).should == '/fi/sections/1'
      end
  
      it 'does not change the section_path when given page option equals 1' do
        section_path(@section, :page => 1).should == '/sections/1'
      end
  
      it 'appends the pages segments to section_path when given page option does not equal 1' do
        section_path(@section, :page => 2).should == '/sections/1/pages/2'
      end
  
      it 'works for section_path with both a locale and page option' do
        section_path(@section, :locale => :fi, :page => 2).should == '/fi/sections/1/pages/2'
      end
    end
  
    describe "a nested resource" do
      # uses optimization
      it 'does not change the section_article_path when the current locale is the default locale and no page option given' do
        section_article_path(@section, @article).should == '/sections/1/articles/1'
      end
  
      # uses optimization
      it 'prepends the current locale to section_article_path when it is not the default locale' do
        I18n.locale = :de
        section_article_path(@section, @article).should == '/de/sections/1/articles/1'
      end
  
      it 'prepends a given locale param to section_article_path when it is not the default locale' do
        I18n.locale = :de
        section_article_path(@section, @article, :locale => :fi).should == '/fi/sections/1/articles/1'
      end
  
      it 'does not change the section_article_path when given page option equals 1' do
        section_article_path(@section, @article, :page => 1).should == '/sections/1/articles/1'
      end
  
      it 'appends the pages segments to section_article_path when given page option does not equal 1' do
        section_article_path(@section, @article, :page => 2).should == '/sections/1/articles/1/pages/2'
      end
  
      it 'works for section_article_path with both a locale and page option' do
        section_article_path(@section, @article, :locale => :fi, :page => 2).should == '/fi/sections/1/articles/1/pages/2'
      end
    end
  end

  describe 'when used with url_for and an ActivRecord instance' do
    describe "a not nested resource" do
      it 'prepends the current locale to section_path when it is not the default locale' do
        I18n.locale = :de
        url_for(@section).should == 'http://test.host/de/sections/1'
      end
    
      it 'does not change the section_path when no page option given' do
        url_for(@section).should == 'http://test.host/sections/1'
      end
    
      it 'does not change the section_path when given page option equals 1' do
        params = @params.update :id => @section, :page => 1
        url_for(params).should == 'http://test.host/sections/1'
      end
    
      it 'appends the pages segments to section_path when given page option does not equal 1' do
        params = @params.update :id => @section, :page => 2
        url_for(params).should == 'http://test.host/sections/1/pages/2'
      end
    
      it 'works for section_path with both a locale and page option' do
        params = @params.update :id => @section, :locale => :fi, :page => 2
        url_for(params).should == 'http://test.host/fi/sections/1/pages/2'
      end
    end
    
    describe "a nested resource" do
      it 'prepends the current locale to section_article_path when it is not the default locale' do
        I18n.locale = :de
        url_for([@section, @article]).should == 'http://test.host/de/sections/1/articles/1'
      end
    
      it 'does not change the section_article_path when no page option given' do
        url_for([@section, @article]).should == 'http://test.host/sections/1/articles/1'
      end
    
      it 'does not change the section_article_path when given page option equals 1' do
        params = @article_params.update :section_id => @section, :id => @article, :page => 1
        url_for(params).should == 'http://test.host/sections/1/articles/1'
      end
    
      it 'appends the pages segments to section_article_path when given page option does not equal 1' do
        params = @article_params.update :section_id => @section, :id => @article, :page => 2
        url_for(params).should == 'http://test.host/sections/1/articles/1/pages/2'
      end

      it 'works for section_article_path with both a locale and page option' do
        params = @article_params.update :section_id => @section, :id => @article, :locale => :fi, :page => 2
        url_for(params).should == 'http://test.host/fi/sections/1/articles/1/pages/2'
      end
    end
  end
end