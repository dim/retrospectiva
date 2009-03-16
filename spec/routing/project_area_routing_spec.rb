require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectAreaController do

  describe 'if there is no main project' do

    before do
      Project.stub!(:central).and_return(false)
    end
    
    it 'should correctly generate routes' do
      route_for(:project_id => 'one', :controller => 'tickets', :action => 'show', :id => '123').should == '/projects/one/tickets/123'
    end

    it 'should correctly recognize routes' do
      params_from(:get, '/projects/one/tickets/123').should == { :project_id => 'one', :controller => 'tickets', :action => 'show', :id => '123' }
    end
        
  end

  describe 'dealing with central projects' do

    before do
      @project = stub_model(Project, :short_name => 'one')
      Project.stub!(:central).and_return(@project)
    end
    
    it 'should correctly generate routes' do
      route_for(:project_id => 'one', :controller => 'tickets', :action => 'show', :id => '123').should == '/tickets/123'     
    end
    
    it 'should correctly recognize routes' do
      params_from(:get, '/tickets/123').should == { :project_id => 'one', :controller => 'tickets', :action => 'show', :id => '123' }
    end

  end
  
end

