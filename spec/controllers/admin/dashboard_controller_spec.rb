require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::DashboardController do
  it_should_behave_like EveryAdminAreaController

  before do
    permit_access!    
  end

  describe "handling GET /admin" do

    def do_get
      get :index      
    end

    it_should_successfully_render_template('index')
  
  end

end
