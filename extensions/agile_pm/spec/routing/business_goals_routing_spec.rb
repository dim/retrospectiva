require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GoalsController do

  before do 
    Project.stub!(:central).and_return(nil)
  end

  it 'should generate home' do
    route_for(:project_id => 'one', :controller => 'goals', :action => 'home').
      should == '/projects/one/goals'
  end

  it 'should recognize home' do
    params_from(:get, '/projects/one/goals').
      should == { :project_id => 'one', :controller => 'goals', :action => 'home' }
  end

  it 'should generate index' do
    route_for(:project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'index').
      should == '/projects/one/milestones/1/goals'
  end

  it 'should recognize index' do
    params_from(:get, '/projects/one/milestones/1/goals').
      should == { :project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'index' }
  end

  it 'should generate create' do
    route_for(:project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'create').
      should == { :path => '/projects/one/milestones/1/goals', :method => :post }
  end

  it 'should recognize create' do
    params_from(:post, '/projects/one/milestones/1/goals').
      should == { :project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'create' }
  end

  it 'should generate new' do
    route_for(:project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'new').
      should == '/projects/one/milestones/1/goals/new'
  end

  it 'should recognize new' do
    params_from(:get, '/projects/one/milestones/1/goals/new').
      should == { :project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'new' }
  end

  it 'should generate edit' do
    route_for(:project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'edit', :id => '2').
      should == '/projects/one/milestones/1/goals/2/edit'
  end

  it 'should recognize edit' do
    params_from(:get, '/projects/one/milestones/1/goals/2/edit').
      should == { :project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'edit', :id => '2' }
  end

  it 'should generate update' do
    route_for(:project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'update', :id => '2').
      should == { :path => '/projects/one/milestones/1/goals/2', :method => :put }
  end

  it 'should recognize update' do
    params_from(:put, '/projects/one/milestones/1/goals/2').
      should == { :project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'update', :id => '2' }
  end
  
  it 'should generate destroy' do
    route_for(:project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'destroy', :id => '2').
      should == { :path => '/projects/one/milestones/1/goals/2', :method => :delete }
  end

  it 'should recognize destroy' do
    params_from(:delete, '/projects/one/milestones/1/goals/2').
      should == { :project_id => 'one', :milestone_id => '1', :controller => 'goals', :action => 'destroy', :id => '2' }
  end
  
end

