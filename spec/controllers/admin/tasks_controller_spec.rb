require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TasksController do
  it_should_behave_like EveryAdminAreaController

  before do
    permit_access!
    @task = mock('Task1')
    @tasks = [@task]
    @parser = mock(Retrospectiva::TaskManager::Parser, :tasks => @tasks)
    Retrospectiva::TaskManager::Parser.stub!(:new).and_return(@parser)
  end

  describe "handling GET /admin/tasks" do
    def do_get
      get :index      
    end

    it_should_successfully_render_template('index')

    it "should query the tasks" do
      Retrospectiva::TaskManager::Parser.should_receive(:new).and_return(@parser)
      @parser.should_receive(:tasks).and_return(@tasks)
      do_get
    end

    it "should assign the tasks for the view" do
      do_get
      assigns[:tasks].should == @tasks
    end
  
  end


  describe "handling PUT /admin/tasks/save" do

    before do
      Retrospectiva::TaskManager::Task.stub!(:update_or_create).and_return @task
    end

    def do_put
      put :save, :tasks => { 'task_a' => { 'count' => '10', 'units' => 'minutes' }}
    end

    it "should reject non-put requests" do
      get :save
      response.code.should == '400'
    end

    it "should find or create the affected task" do
      Retrospectiva::TaskManager::Task.should_receive(:create_or_update).with('task_a', 600).and_return @task
      do_put
    end
          
    it "should redirect to task overview" do
      do_put
      response.should be_redirect
      response.should redirect_to(admin_tasks_path)
    end
    
  end

end
