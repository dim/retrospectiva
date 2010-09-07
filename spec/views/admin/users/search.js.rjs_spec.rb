require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/search.js.rjs" do
  
  before(:each) do
    stub_current_user! :admin? => true
    @user = stub_model(User, :groups => [stub_model(Group)])
    user_2 = stub_model(User)

    assigns[:users] = [@user, user_2].paginate(:per_page => 1)
  end

  def do_render
    render "/admin/users/search.js.rjs", :helpers => ['admin_area', 'application']
  end
  
  it "should update the users" do
    do_render
    response.should have_rjs(:replace_html, 'users', :partial => 'user', :collection => @users)
  end

  it "should hide pagination if a search term is given" do
    template.params[:term] = 'word'
    do_render
    response.body.should match(/el\.hide\(\)/)
  end            

  it "should show pagination if a search term is blank" do
    template.params[:term] = ''
    do_render
    response.body.should match(/el\.show\(\)/)
  end            

end

