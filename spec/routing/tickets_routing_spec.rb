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
      { :path => '/projects/one/tickets/123/modify_summary', :method => :put }
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
      { :path => '/projects/one/tickets/123/456', :method => :delete }
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
  
  it 'should correctly recognize params for toggle-subscription' do
    route_for(:project_id => 'one', :controller => 'tickets', :action => 'toggle_subscription', :id => '123').should == 
      { :path => '/projects/one/tickets/123/toggle_subscription', :method => :post }
  end

  
  describe 'modify-summary' do

    it 'should correctly recognize params' do
      params_from(:put, '/projects/one/tickets/123/modify_summary').should ==
        { :project_id => 'one', :controller => 'tickets', :action => 'modify_summary', :id => '123' }
    end

    it 'should reject non-PUT requests' do
      lambda { 
        params_from(:get, '/projects/one/tickets/123/modify_summary').should ==
          { :project_id => 'one', :controller => 'tickets', :action => 'modify_summary', :id => '123' }
      }.should raise_error(ActionController::MethodNotAllowed, 'Only put requests are allowed.') 
    end
  
  end

  describe 'modify-content' do

    it 'should correctly recognize params' do
      params_from(:put, '/projects/one/tickets/123/modify_content').should ==
        { :project_id => 'one', :controller => 'tickets', :action => 'modify_content', :id => '123' }
    end

    it 'should reject non-PUT requests' do
      lambda { 
        params_from(:get, '/projects/one/tickets/123/modify_content').should ==
          { :project_id => 'one', :controller => 'tickets', :action => 'modify_content', :id => '123' }
      }.should raise_error(ActionController::MethodNotAllowed, 'Only put requests are allowed.') 
    end
  
  end

  describe 'modify-change-content' do

    it 'should correctly recognize params' do
      params_from(:put, '/projects/one/tickets/123/modify_change_content').should ==
        { :project_id => 'one', :controller => 'tickets', :action => 'modify_change_content', :id => '123' }
    end

    it 'should reject non-PUT requests' do
      lambda { 
        params_from(:get, '/projects/one/tickets/123/modify_change_content').should ==
          { :project_id => 'one', :controller => 'tickets', :action => 'modify_change_content', :id => '123' }
      }.should raise_error(ActionController::MethodNotAllowed, 'Only put requests are allowed.') 
    end
  
  end

  describe 'destroy-change' do

    it 'should correctly generate params' do
      route_for(:project_id => 'one', :controller => 'tickets', :action => 'destroy_change', :ticket_id => '123', :id => '45').should ==
        { :path => '/projects/one/tickets/123/45', :method => :delete }
    end

    it 'should correctly recognize params' do
      params_from(:delete, '/projects/one/tickets/123/45').should ==
        { :project_id => 'one', :controller => 'tickets', :action => 'destroy_change', :ticket_id => '123', :id => '45' }
    end

    it 'should reject non-DELETE requests' do
      lambda { 
        params_from(:get, '/projects/one/tickets/123/45').should ==
          { :project_id => 'one', :controller => 'tickets', :action => 'destroy_change', :ticket_id => '123', :id => '45' }
      }.should raise_error(ActionController::MethodNotAllowed, 'Only delete requests are allowed.') 
    end
  
  end



end
