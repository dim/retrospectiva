require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::SetupController do

  it 'should correctly generate params for index' do
    params_from(:get, '/admin/setup').should == 
      { :controller => 'admin/setup', :action => 'index' }
  end

  it 'should correctly generate params for save' do
    params_from(:put, '/admin/setup').should == 
      { :controller => 'admin/setup', :action => 'save' }
  end
  
  it 'should correctly recognize params for index' do
    route_for(:controller => 'admin/setup', :action => 'index').should == '/admin/setup' 
  end

  it 'should correctly recognize params for save' do
    route_for(:controller => 'admin/setup', :action => 'save').should == { :path => '/admin/setup', :method => :put } 
  end

end
