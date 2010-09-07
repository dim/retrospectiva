require File.dirname(__FILE__) + '/../../spec_helper'

describe "/search/index.html.erb" do
  
  before do 
    @project = stub_current_project! :name => 'Retrospectiva'
    @user = stub_current_user! :has_access? => true
    template.stub!(:channel_checkboxes).and_return('[CHECKBOXES]')
    assigns[:results] = []
  end
  
  def do_render
    render '/search/index'
  end
  
  it 'should render the form' do
    do_render
    response.should have_tag('form') do
      with_submit_button
      with_tag 'fieldset', '[CHECKBOXES]'
    end
  end
  
  describe 'if results are available' do
    before do 
      @previewable = mock 'Previewable', 
        :path => '/tickets/1', 
        :title => 'A Ticket', 
        :description => 'Ticket Summary'
      @result = mock('Result', :previewable => @previewable)
      assigns[:results] = [@result]
    end    
    
    it 'should render results' do
      template.should_receive(:highlight_matches).with('A Ticket', nil).and_return('[TITLE EXCERPT]')
      template.should_receive(:highlight_matches).with('Ticket Summary', nil).and_return('[CONTENT EXCERPT]')
      do_render
      response.should have_tag('h3', '[TITLE EXCERPT]')
      response.should have_tag('p', '[CONTENT EXCERPT]')
    end
        
  end
  
end
