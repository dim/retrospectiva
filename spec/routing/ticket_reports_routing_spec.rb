require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketReportsController do
  describe "route generation" do
  
    it "maps #new" do
      route_for(:controller => "ticket_reports", :action => "new", :project_id => 'retro').should == "/projects/retro/ticket_reports/new"
    end
  
    it "maps #create" do
      route_for(:controller => "ticket_reports", :action => "create", :project_id => 'retro').should == {:path => "/projects/retro/ticket_reports", :method => :post}
    end

    it "maps #destroy" do
      route_for(:controller => "ticket_reports", :action => "destroy", :project_id => 'retro', :id => "1").should == {:path =>"/projects/retro/ticket_reports/1", :method => :delete}
    end

    it "maps #sort" do
      route_for(:controller => "ticket_reports", :action => "sort", :project_id => 'retro').should == {:path =>"/projects/retro/ticket_reports/sort", :method => :put}
    end
  end

  describe "route recognition" do
  
    it "generates params for #new" do
      params_from(:get, "/projects/retro/ticket_reports/new").should == {:controller => "ticket_reports", :action => "new", :project_id => 'retro'}
    end
  
    it "generates params for #create" do
      params_from(:post, "/projects/retro/ticket_reports").should == {:controller => "ticket_reports", :action => "create", :project_id => 'retro'}
    end
    
    it "generates params for #destroy" do
      params_from(:delete, "/projects/retro/ticket_reports/1").should == {:controller => "ticket_reports", :action => "destroy", :project_id => 'retro', :id => "1"}
    end

    it "generates params for #sort" do
      params_from(:put, "/projects/retro/ticket_reports/sort").should == {:controller => "ticket_reports", :action => "sort", :project_id => 'retro'}
    end
    
  end
end
