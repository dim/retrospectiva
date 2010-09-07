require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupController do

  describe 'GET /reference' do
    
    before do
      @examples = ActiveSupport::OrderedHash.new()
      @examples['Links'] = []
      @examples['References'] = []
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
      assigns[:examples]['Links'].should have(5).records
      assigns[:examples]['References'].should have(3).records
    end
    
  end

end
