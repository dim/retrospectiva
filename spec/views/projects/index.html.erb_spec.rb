require File.dirname(__FILE__) + '/../../spec_helper'

describe "/projects/index.html.erb" do

  describe 'if no projects were found' do

    before do 
      template.stub!(:auto_discover_feed)
      assigns[:projects] = []
      render '/projects/index'
    end
   
    it 'should indicate that not projects are not availale' do
      response.should have_tag('h2', 'No projects available')
    end
  end
  
  describe 'if no projects were found' do
    before do 
      @p1, @p2 = mock_model(Project, :name => 'P1', :info => 'I1'), mock_model(Project, :name => 'P2', :info => nil)
      assigns[:projects] = [@p1, @p2]
      render '/projects/index'
    end
   
    it 'should display the project names with links' do
      response.should have_tag('h2 a[href=?]', project_path(@p1), 'P1')
      response.should have_tag('h2 a[href=?]', project_path(@p2), 'P2')
    end

    it 'should display the project info in hidden tags (if any)' do
      response.should have_tag('div[id=?]', "project_info_#{@p1.id}", 'I1')
      response.should_not have_tag('div[id=?]', "project_info_#{@p2.id}")
    end
  end
end