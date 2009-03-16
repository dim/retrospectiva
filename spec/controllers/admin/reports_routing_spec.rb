require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ReportsController do

  it 'should correctly generate params for index' do
    params_from(:get, '/admin/projects/123/reports').should == 
      { :controller => 'admin/reports', :action => 'index', :project_id => '123' }
  end

  it 'should correctly generate params for show' do
    params_from(:get, '/admin/projects/123/reports/1').should == 
      { :controller => 'admin/reports', :action => 'show', :project_id => '123', :id => '1' }
  end

  it 'should correctly generate params for new' do
    params_from(:get, '/admin/projects/123/reports/new').should == 
      { :controller => 'admin/reports', :action => 'new', :project_id => '123' }
  end

  it 'should correctly generate params for edit' do
    params_from(:get, '/admin/projects/123/reports/1/edit').should == 
      { :controller => 'admin/reports', :action => 'edit', :project_id => '123', :id => '1' }
  end

  it 'should correctly generate params for create' do
    params_from(:post, '/admin/projects/123/reports').should == 
      { :controller => 'admin/reports', :action => 'create', :project_id => '123' }
  end
  
  it 'should correctly generate params for update' do
    params_from(:put, '/admin/projects/123/reports/1').should == 
      { :controller => 'admin/reports', :action => 'update', :project_id => '123', :id => '1' }
  end

  it 'should correctly generate params for destroy' do
    params_from(:delete, '/admin/projects/123/reports/1').should == 
      { :controller => 'admin/reports', :action => 'destroy', :project_id => '123', :id => '1' }
  end

  it 'should correctly generate params for sort' do
    params_from(:put, '/admin/projects/123/reports/sort').should == 
      { :controller => 'admin/reports', :action => 'sort', :project_id => '123' }
  end
  
  
  it 'should correctly recognize params for index' do
    route_for(:controller => 'admin/reports', :action => 'index', :project_id => '123').should == '/admin/projects/123/reports' 
  end

  it 'should correctly recognize params for show' do
    route_for(:controller => 'admin/reports', :action => 'show', :project_id => '123', :id => '1').should == '/admin/projects/123/reports/1' 
  end

  it 'should correctly recognize params for new' do
    route_for(:controller => 'admin/reports', :action => 'new', :project_id => '123').should == '/admin/projects/123/reports/new' 
  end

  it 'should correctly recognize params for edit' do
    route_for(:controller => 'admin/reports', :action => 'edit', :project_id => '123', :id => '1').should == '/admin/projects/123/reports/1/edit' 
  end

  it 'should correctly recognize params for create' do
    route_for(:controller => 'admin/reports', :action => 'create', :project_id => '123').should == { :path => '/admin/projects/123/reports', :method => :post } 
  end
  
  it 'should correctly recognize params for update' do
    route_for(:controller => 'admin/reports', :action => 'update', :project_id => '123', :id => '1').should == { :path => '/admin/projects/123/reports/1', :method => :put } 
  end

  it 'should correctly recognize params for destroy' do
    route_for(:controller => 'admin/reports', :action => 'destroy', :project_id => '123', :id => '1').should ==  { :path => '/admin/projects/123/reports/1', :method => :delete } 
  end

  it 'should correctly recognize params for sort' do
    route_for(:controller => 'admin/reports', :action => 'sort', :project_id => '123').should == { :path => '/admin/projects/123/reports/sort', :method => :put } 
  end

end
