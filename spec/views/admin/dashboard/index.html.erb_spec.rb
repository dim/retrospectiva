require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/dashboard/index.html.erb" do
      
  def do_render
    render '/admin/dashboard/index'
  end
  
  it 'should display the navigation' do
    template.should_receive(:link_to).exactly(8).times
    do_render
    response.should be_success
  end

end