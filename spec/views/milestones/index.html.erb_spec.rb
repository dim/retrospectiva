require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/milestones/index.html.erb" do
  include MilestonesHelper
  
  before(:each) do
    @user = mock_current_user! :permitted? => false
    @project = mock_current_project!
    @milestone = mock_model Milestone, 
      :due => nil, :completed? => false, :name => 'M1', :info => 'I1', 
      :open_tickets => 0, :closed_tickets => 0, :in_prgress_tickets => 0, :percent_in_progress => 0, :percent_completed => 0
    milestone_2 = mock_model(Milestone)

    assigns[:milestones] = [@milestone, milestone_2].paginate(:per_page => 1)
  end

  describe 'in general' do    
    before do
      render "/milestones/index.html.erb"
    end
    
    it "should render list of milestones" do
      response.should have_tag('div.milestone', 1)
    end

    it "should show link to show completed" do
      response.should have_tag('div.content-header') do
        with_tag 'a[href=?]', project_milestones_path(@project, :completed => 1)
      end      
    end            

    it "should show link to show pagination" do
      response.should have_tag('div.content-footer') do
        with_tag 'a[href=?]', project_milestones_path(@project, :page => 2)
      end      
    end
  end

  describe 'if user has permission to edit milestones' do    
    before do
      @user.should_receive(:permitted?).with(:milestones, :edit).and_return(true)
      render "/milestones/index.html.erb"
    end

    it "should show link to edit milestone" do
      with_tag 'a[href=?]', edit_project_milestone_path(@project, @milestone), 'Edit'
    end            
  end

  describe 'if user has permission to delete milestones' do    
    before do
      @user.should_receive(:permitted?).with(:milestones, :delete).and_return(true)
      render "/milestones/index.html.erb"
    end

    it "should show link to delete milestone" do
      with_tag('a[href=?]', project_milestone_path(@project, @milestone), 'Delete')
    end            
  end

  describe 'if show-completed is selected' do    
    before do
      template.params[:completed] = '1'      
      render "/milestones/index.html.erb"
    end

    it "should show link to hide completed" do
      response.should have_tag('div.content-header') do
        with_tag 'a[href=?]', project_milestones_path(@project)
      end      
    end            
  end

end

