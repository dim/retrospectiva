require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/extensions/index.html.erb" do
  
  before do 
    ext_a = mock_model(RetroEM::Extension, :name => 'ext_a', :installed? => true)
    ext_b = mock_model(RetroEM::Extension, :name => 'ext_b', :installed? => false)
    assigns[:available] = [ext_a, ext_b]
    template.stub!(:breadcrumbs).and_return('<div>BREADCRUMBS</div>')
  end      

  def do_render
    render '/admin/extensions/index'
  end

  it 'should display the breadcrumbs' do
    do_render
    response.should have_tag('div', 'BREADCRUMBS')
  end
  
  it 'should display the extensions' do
    do_render
    response.should have_tag('img[title=?]', 'Installed')
    response.should have_tag('img[title=?]', 'Not Installed')
  end

end