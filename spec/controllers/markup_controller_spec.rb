require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupController do

  describe 'GET /reference' do
    
    before do
      @examples = ActiveSupport::OrderedHash.new()
      @examples['Links'] = []
      @engine = mock 'WikiEngine', :markup_examples => @examples 
    end
    
    def do_get
      get :reference
    end
    
    it 'should load the examples' do
      WikiEngine.should_receive(:default_engine).and_return(@engine)
      @engine.should_receive(:markup_examples).and_return(@examples)
      do_get
      assigns[:examples].should == @examples      
      @examples['Links'].should have(2).records
    end
    
  end

  describe 'POST /preview' do
    integrate_views
    
    def do_post
      xhr :post, :preview, :content => '', :element_id => 'content_editor', :format => 'js'
    end
    
    it 'should reject non-xhr requests' do
      post  :preview, :element_id => 'content_editor', :format => 'js'
      response.code.should == '400'      
    end

    it 'should reject requests without an element ID' do
      xhr :post,  :preview, :format => 'js'
      response.code.should == '400'      
    end
    
    it 'should load the template' do
      do_post
      response.should be_success
      response.should render_template(:preview)
    end
    
  end

end
