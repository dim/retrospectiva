require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketsController do

  it 'should correctly generate params for modify-summary' do
    params_from(:put, '/projects/one/tickets/123/modify_summary').should == 
      { :project_id => 'one', :controller => 'tickets', :action => 'modify_summary', :id => '123' }
    lambda { 
      params_from(:get, '/projects/one/tickets/123/modify_summary')
    }.should raise_error(ActionController::MethodNotAllowed, 'Only put requests are allowed.') 
  end
  
  it 'should correctly recognize params for modify-summary' do
    route_for(:project_id => 'one', :controller => 'tickets', :action => 'modify_summary', :id => '123').should == 
      '/projects/one/tickets/123/modify_summary'
  end


  it 'should correctly generate params for destroy-change' do
    params_from(:delete, '/projects/one/tickets/123/456').should == 
      { :project_id => 'one', :controller => 'tickets', :action => 'destroy_change', :ticket_id => '123', :id => '456' }    
    lambda { 
      params_from(:get, '/projects/one/tickets/123/456')
    }.should raise_error(ActionController::MethodNotAllowed, 'Only delete requests are allowed.') 
  end
  
  it 'should correctly recognize params for destroy-change' do
    route_for(:project_id => 'one', :controller => 'tickets', :action => 'destroy_change', :ticket_id => '123', :id => '456').should == 
      '/projects/one/tickets/123/456'
  end


  it 'should correctly generate params for download' do
    params_from(:get, '/projects/one/tickets/123/download/456/document.txt').should == 
      { :project_id => 'one', :controller => 'tickets', :action => 'download', :ticket_id => '123', :id => '456', :file_name => 'document.txt' }    
  end

  it 'should verify presence of file-name on download' do
    lambda { 
      params_from(:get, '/projects/one/tickets/123/download/456/')  
    }.should raise_error(ActionController::RoutingError) 
  end
  
  it 'should correctly recognize params for download' do
    route_for(:project_id => 'one', :controller => 'tickets', :action => 'download', :ticket_id => '123', :id => '456', :file_name => 'document.txt').should == 
      '/projects/one/tickets/123/download/456/document.txt'
  end


  it 'should correctly generate params for toggle-subscription' do
    params_from(:post, '/projects/one/tickets/123/toggle_subscription').should == 
      { :project_id => 'one', :controller => 'tickets', :action => 'toggle_subscription', :id => '123' }    
    lambda { 
      params_from(:get, '/projects/one/tickets/123/toggle_subscription')
    }.should raise_error(ActionController::MethodNotAllowed, 'Only post requests are allowed.') 
  end
  
  it 'should correctly recognize params for destroy-change' do
    route_for(:project_id => 'one', :controller => 'tickets', :action => 'toggle_subscription', :id => '123').should == 
      '/projects/one/tickets/123/toggle_subscription'
  end

end
