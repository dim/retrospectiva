require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectAreaController do

  before do 
    @user = mock_current_user! :admin? => true, :name => 'Agent'
    @project = mock_current_project! :enabled_modules => [], :name => 'Retro'
    @item = mock(RetroAM::MenuMap::Item, :name => 'Item', :active? => true)       
    RetroAM.menu_items.stub!(:find).and_return(@item)    
  end

  describe 'extended authorization requirements' do
    
    before do 
      RetroAM.stub!(:menu_items).and_return([@item])   
      ProjectAreaController.stub!(:module_enabled?).and_return(true)
      ProjectAreaController.stub!(:module_accessible?).and_return(true)
    end
    
    def authorize?(action_name = 'index', request_params = {})
      ProjectAreaController.authorize?(action_name, request_params, @user, @project)
    end    

    it 'should find the requested menu-item' do
      RetroAM.should_receive(:menu_items).and_return([@item])   
      authorize?
    end
    
    it 'should verify that requested menu-item is enabled for the selected project' do
      ProjectAreaController.should_receive(:module_enabled?).with(@project, @item).and_return(true)      
      authorize?
    end

    it 'should verify that requested menu-item is accessible by the current user for the selected project' do
      ProjectAreaController.should_receive(:module_accessible?).with(@project, @item).and_return(true)      
      authorize?
    end
    
    describe 'if menu-item is not enabled' do
      before do
        ProjectAreaController.stub!(:module_enabled?).and_return(false)       
      end
      
      it 'should return false and deny authorization' do              
        authorize?.should == false
      end      
    end
    
    describe 'if menu-item is not accessible' do
      before do
        ProjectAreaController.stub!(:module_accessible?).and_return(false)       
      end
      
      it 'should return false and deny authorization' do              
        authorize?.should == false
      end      
    end

    describe 'if menu-item IS enabled AND accessible' do      
      it 'should proceed with the default authorization process' do              
        authorize?.should == true
      end
    end
    
  end

  describe 'check if a menu-item is enabled' do
    
    it 'should verify that the given item is enabled for the given project' do
      @project.enabled_modules.should_receive(:include?).with('Item').and_return(true)
      ProjectAreaController.send(:module_enabled?, @project, @item).should == true
    end
    
  end

  describe 'check if a menu-item is accessible' do
    
    it 'should verify that the given item can be accessed within the given project' do
      @item.should_receive(:accessible?).with(@project).and_return(true)
      ProjectAreaController.send(:module_accessible?, @project, @item).should == true
    end
    
  end

end

describe "Authorization" do
  controller_name :search
  
  before do
    @project = mock_current_project! :enabled_modules => [], :name => 'Retro'
    @projects = [@project]
    @projects.stub!(:find!).and_return(@project)
    @user = mock_current_user! :name => 'Doesnt Matter'
    @user.stub!(:active_projects).and_return(@projects)
    @user.stub!(:has_access?).and_return(true)      
  end       
  
  def do_get
    get :index, :project_id => 'one'
  end
  
  describe 'if a user is already logged in' do
    
    before do
      @user.stub!(:public?).and_return(false)
    end
    
    describe 'and if user is permitted to see page' do
      before do
        controller.class.stub!(:authorize?).and_return(true)          
      end
      
      it 'should display the page' do
        do_get
        response.should be_success
      end

      it 'should not store request path' do
        do_get
        session[:back_to].should be_nil
      end
    end    

    describe 'and if user is not permitted to see page' do
      before do
        rescue_action_in_public!
        controller.stub!(:consider_all_requests_local).and_return(false)
        controller.class.stub!(:authorize?).and_return(false)          
      end
      
      it 'should display forbidden page' do
        do_get
        response.code.should == '403'
        response.should render_template(RAILS_ROOT + '/app/views/rescue/403.html.erb')
      end

      it 'should not store request path' do
        do_get
        session[:back_to].should be_nil
      end
    end    

  end

  describe 'if a user is NOT logged in' do
    
    before do
      @user.stub!(:public?).and_return(true)
    end
          
    describe 'and if user is permitted to see page' do
      before do
        controller.class.stub!(:authorize?).and_return(true)          
      end
      
      it 'should display the page' do
        do_get
        response.should be_success
      end

      it 'should not store request path' do
        do_get
        session[:back_to].should be_nil
      end
    end    

    describe 'and if user is not permitted to see page' do
      before do
        controller.class.stub!(:authorize?).and_return(false)          
      end
              
      it 'should redirect to login page' do
        do_get
        response.should redirect_to(login_path)
      end

      it 'should store the request path' do
        do_get
        session[:back_to].should == '/projects/one/search'
      end
      
      describe 'and if relative URL root is set' do
        
        before do
          ActionController::Base.stub!(:relative_url_root).and_return('/dev')
        end
        
        it 'should store the request path correctly' do
          do_get
          session[:back_to].should == '/dev/projects/one/search'
        end
        
      end
      
    end    

  end
end
