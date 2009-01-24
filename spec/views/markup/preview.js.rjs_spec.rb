require File.dirname(__FILE__) + '/../../spec_helper'

describe "/markup/preview.js.rjs" do
  
  before do 
    template.stub!(:params).and_return(:element_id => '[ID]', :content => '[CONTENT]')    
    template.stub!(:markup)
  end
  
  it 'should render the preview' do
    template.should_receive(:markup).with('[CONTENT]').and_return('[MARKUP]')
    render '/markup/preview.js.rjs'
    response.should have_rjs(:replace_html)
  end
  
end
