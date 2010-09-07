require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/repositories/new.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    assigns[:repository] = @repository = mock_model(Repository::Subversion, 
      :name => 'R1', :kind => 'Subversion', :path => '/home/me/repo', :sync_callback => nil)
  end

  def do_render
    render "/admin/repositories/new.html.erb", :helper => 'admin_area'
  end
    
  it "should render the form" do
    do_render
    response.should have_form_posting_to(admin_repositories_path) do
      with_submit_button
      with_link_to(admin_repositories_path)
    end
  end

  it "should render the page header" do
    template.should_receive(:render).with(:partial => 'header')
    do_render
  end

end

