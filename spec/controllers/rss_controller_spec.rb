require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RssController do

  before do
    @user = mock_model(User, :public? => false, :time_zone => 'London')
    User.stub!(:current).and_return(@user)    
  end

  describe 'GET /index' do

    before do
      @project_a = mock_model(Project, :to_param => '1')
      @project_b = mock_model(Project, :to_param => '1')
      @projects = [@project_a, @project_b]
      @projects.stub!(:active).and_return(@projects)      
      @user.stub!(:projects).and_return(@projects)      
      controller.stub!(:load_channels).and_return({})
    end      

    it 'should load the active user projects' do
      @user.should_receive(:projects).and_return(@projects)
      get :index            
    end
    
    it 'should load and assign the channels for each project' do
      controller.should_receive(:load_channels).with(:feedable?, @project_a).and_return({})
      controller.should_receive(:load_channels).with(:feedable?, @project_b).and_return({ 'channel' => [Changeset] })
      get :index
      assigns[:project_map].should be_kind_of(ActiveSupport::OrderedHash) 
      assigns[:project_map].to_a.should == [[@project_b, { 'channel' => [Changeset] }]] 
    end

    it 'should render the template' do
      get :index
      response.should be_success
      response.should render_template(:index)       
    end
  
  end

end
