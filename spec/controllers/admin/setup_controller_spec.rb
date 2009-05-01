require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::SetupController do
  it_should_behave_like EveryAdminAreaController

  before do
    permit_access!    
    controller.stub!(:set_locale).and_return(true)
    @sections = [mock('RetroCM::Section1', :name => 'Section1')]
    @configuration = mock_model(RetroCM::Configuration)
    RetroCM[:general][:basic].setting(:site_url).stub!(:default?).and_return(false)        
  end

  describe "handling GET /admin/setup" do
    def do_get
      get :index
    end
    it_should_successfully_render_template('index')

    it "should query the configuration sections and assign them for the view" do
      controller.stub!(:validate_site_url)
      RetroCM.should_receive(:sections).and_return(@sections)
      do_get
      assigns[:sections].should == @sections
    end

    it "should assign the configuration for the view" do
      controller.stub!(:validate_site_url)
      RetroCM.should_receive(:configuration).and_return(@configuration)
      do_get
      assigns[:configuration].should == @configuration
    end

    describe 'if the Site-URL has not been changed by the user' do
      
      before do
        RetroCM[:general][:basic].setting(:site_url).stub!(:default?).and_return(true)        
      end
      
      it 'should automatically use current URL to in the setup' do
        do_get
        RetroCM[:general][:basic][:site_url].should == 'http://test.host'
      end
      
    end
  
  end


  describe "handling PUT /admin/setup/save" do

    before do
      controller.stub!(:validate_site_url)
      @sections = [mock('RetroCM::Section1')]
      RetroCM.stub!(:sections).and_return(@sections)
    end

    def do_put
      put :save, :retro_cf => {}
    end

    it "should reject non-put requests" do
      get :save
      response.code.should == '400'
    end
    
    describe 'with correct update values' do

      before do
        RetroCM.stub!(:update).and_return true
      end
      
      it "should update the configuration" do
        RetroCM.should_receive(:update).with({}).and_return true
        do_put
      end

      it "should redirect to setup overview" do
        do_put
        response.should be_redirect
        response.should redirect_to(admin_setup_path)
      end

    end

    describe 'with incorrect update values' do

      before do
        RetroCM.stub!(:update).and_return false
      end

      it "should reload configuration sections" do
        RetroCM.should_receive(:sections).and_return(@sections)
        do_put
      end

      it_should_successfully_render_template('index', :do_put)
      
    end
  
  end

end
