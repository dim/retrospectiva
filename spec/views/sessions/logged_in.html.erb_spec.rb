require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sessions/logged_in.html.erb" do

  before do 
    User.stub!(:current).and_return(mock_model(User, :name => 'U1', :username => 'u1'))
    render '/sessions/logged_in'
  end
   
  it 'should indicate session status' do
    response.should have_tag('p', /logged in to the system/)
  end

  it 'should show a link to home' do
    response.should have_tag('a[href=?]', root_path)
  end

  it 'should show a link to logout' do
    response.should have_tag('a[href=?]', logout_path)
  end
end