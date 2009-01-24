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
      WikiEngine.should_receive(:default).and_return(@engine)
      @engine.should_receive(:markup_examples).and_return(@examples.dup)
      do_get
      assigns[:examples].should == @examples
      @examples['Links'].should have(2).records
    end
    
  end

end
