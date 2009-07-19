require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TasksController do
  it_should_behave_like EveryAdminAreaController

  before do
    permit_access!
    @task = mock_model(Retrospectiva::TaskManager::Task)
    @tasks = [@task]
    @parser = mock(Retrospectiva::TaskManager::Parser, :tasks => @tasks)
    Retrospectiva::TaskManager::Parser.stub!(:new).and_return(@parser)
  end

  describe "GET index" do
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


  describe "PUT save" do

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

  describe "PUT update (reset)" do

    def now
      @now ||= Time.zone.now 
    end

    before do
      @task.stub!(:stale?).and_return(false)
      @task.stub!(:started_at).and_return(now)
      Retrospectiva::TaskManager::Task.stub!(:find).and_return @task
    end

    def do_put
      put :update, :id => '37'
    end

    it "should assign the task" do
      Retrospectiva::TaskManager::Task.should_receive(:find).with('37').and_return @task
      do_put
      assigns[:task].should == @task
    end
          
    it "should redirect to task overview" do
      do_put
      response.should redirect_to(admin_tasks_path)
    end

    it "should reset task if stale" do
      @task.should_receive(:stale?).and_return(true)
      @task.should_receive(:update_attribute).with(:finished_at, now)
      do_put
    end
    
  end

end
