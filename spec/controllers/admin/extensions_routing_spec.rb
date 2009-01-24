require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ExtensionsController do

  it 'should correctly generate params for index' do
    params_from(:get, '/admin/extensions').should == 
      { :controller => 'admin/extensions', :action => 'index' }
  end

  it 'should correctly recognize params for index' do
    route_for(:controller => 'admin/extensions', :action => 'index').should == '/admin/extensions' 
  end


end
