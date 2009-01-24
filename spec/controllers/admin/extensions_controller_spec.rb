require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ExtensionsController do
  it_should_behave_like EveryAdminAreaController

  before do
    permit_access!    
  end

  describe "handling GET /admin/extensions" do
    
    before do
      @available = [mock('RetroEM::Ext1'), mock('RetroEM::Ext2')]
      RetroEM.stub!(:available_extensions).and_return(@available)
    end
    
    def do_get
      get :index      
    end

    it_should_successfully_render_template('index')

    it "should query the extension status" do
      RetroEM.should_receive(:available_extensions).and_return(@available)
      do_get
    end

    it "should assign the extensions for the view" do
      do_get
      assigns[:available].should == @available
    end
  
  end

end
