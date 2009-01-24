require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TasksController do
  it_should_behave_like EveryAdminAreaController

  before do
    permit_access!
    @tasks = [mock('Task1')]
    Retrospectiva::Tasks.stub!(:tasks).and_return(@tasks)
  end

  describe "handling GET /admin/tasks" do
    def do_get
      get :index      
    end

    it_should_successfully_render_template('index')

    it "should query the tasks" do
      Retrospectiva::Tasks.should_receive(:tasks).and_return(@tasks)
      do_get
    end

    it "should assign the tasks for the view" do
      do_get
      assigns[:tasks].should == @tasks
    end
  
  end


  describe "handling PUT /admin/tasks/save" do

    before do
      Retrospectiva::Tasks.stub!(:update).and_return true
    end

    def do_put
      put :save, :tasks => { 'task_a' => { 'count' => '10', 'units' => 'minutes' }}
    end

    it "should reject non-put requests" do
      get :save
      response.code.should == '400'
    end
          
    it "should update the configuration" do
      Retrospectiva::Tasks.should_receive(:update).with('task_a' => 600).and_return true
      do_put
    end

    it "should redirect to task overview" do
      do_put
      response.should be_redirect
      response.should redirect_to(admin_tasks_path)
    end
    
  end

end
