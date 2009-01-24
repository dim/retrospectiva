require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sessions/destroy.html.erb" do

  before do 
    render '/sessions/destroy'
  end
   
  it 'should confirm log-out' do
    response.should have_tag('p', /logged out of the system/)
  end

end