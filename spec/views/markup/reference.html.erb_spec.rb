require File.dirname(__FILE__) + '/../../spec_helper'

describe "/markup/reference.html.erb" do
  
  before do
    template.stub!(:main_navigation).and_return('<li>[NAVIGATION]</li>')
    assigns[:examples] = [
      ['Tables', ['Example A', 'Example B']]
    ]
    template.stub!(:markup).and_return('[MARKUP]')
  end
  
  def do_render
    render '/markup/reference' 
  end
  
  it 'should render the navigation' do
    template.should_receive(:main_navigation).and_return('<li>[NAVIGATION]</li>')
    do_render
    response.should have_tag('ul#main-navigation li', '[NAVIGATION]')
  end
  
  it 'should render the content' do
    template.should_receive(:markup).with('Example A').and_return('[MARKUP A]')
    template.should_receive(:markup).with('Example B').and_return('[MARKUP B]')
    do_render

    response.should have_tag('h1', 'Tables')
    response.should have_tag('table.examples') do
      with_tag 'tr th', 'Example A'
      with_tag 'tr td', '[MARKUP A]'
      with_tag 'tr th', 'Example B'
      with_tag 'tr td', '[MARKUP B]'
    end        
  end
  
end
