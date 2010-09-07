require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectAreaController do

  before do 
    @user = stub_current_user! :admin? => true, :name => 'Agent'
    @project = stub_current_project! :enabled_modules => [], :name => 'Retro'
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
      controller.class.authorize?(action_name, request_params, @user, @project)
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


describe 'real-world behaviour' do
  controller_name :milestones
    
  before do
    @user = stub_current_user! :name => 'Public', :public? => true, :admin? => false, :permitted? => false
    @project = stub_model Project,
      :name => 'Retro', :short_name => 'retro',
      :enabled_modules => ['milestones']

    @projects = [@project]    
    @projects.stub!(:active).and_return(@projects)
    @projects.stub!(:find).and_return(@project)    

    @milestones = []
    @milestones.stub!(:in_default_order).and_return(@milestones)
    @milestones.stub!(:active_on).and_return(@milestones)
    @project.stub!(:milestones).and_return(@milestones)
  end
  
  def do_get(name = 'retro')
    get :index, :project_id => name
  end
  
  it 'should find the project' do
    Project.should_receive(:find_by_short_name!).and_return(@project)
    @user.stub!(:projects).and_return(@projects)
    do_get
  end

  describe 'if a project genuinely does not exist' do
    
    it 'should raise an error (404)' do
      lambda { do_get('not-there') }.should raise_error(ActiveRecord::RecordNotFound)      
    end    
    
  end

  describe 'if a project exists' do
   
    before do
      Project.stub!(:find_by_short_name!).and_return(@project)      
      @user.stub!(:projects).and_return(@projects)
    end
    
    it 'should find the project within active user-projects' do
      @user.should_receive(:projects).and_return(@projects)
      @projects.should_receive(:active).and_return(@projects)
      @projects.should_receive(:find).with('retro').and_return(@project)
      do_get
    end
    
    describe 'if the project cannot be found within active user-projects' do
      
      it 'should redirect to login' do
        @projects.should_receive(:find).with('retro').and_return(nil)
        do_get
        response.should redirect_to(login_path)
      end
      
    end       
  
  end  
end

