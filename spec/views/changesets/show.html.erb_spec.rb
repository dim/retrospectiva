require File.dirname(__FILE__) + '/../../spec_helper'

describe "/changesets/show.html.erb" do

  before do 
    @repository = stub_model(Repository::Subversion)
    @project = mock_current_project! :repository => @repository
    @project.stub!(:relativize_path).with('added.rb').and_return('added.rb')
    @project.stub!(:relativize_path).with('modified.rb').and_return('modified.rb')
    @project.stub!(:relativize_path).with('moved_from.rb').and_return('moved_from.rb')
    @project.stub!(:relativize_path).with('moved_to.rb').and_return('moved_to.rb')
    @user = mock_current_user! :has_access? => true

    @c1 = mock_model Change, 
      :name => 'M', :path => '/retro/modified.rb', :revision => 'R10', :diffable? => true,
      :unified_diff => <<END_DIFF
--- Revision R5
+++ Revision R10
@@ -4,6 +4,22 @@
   fixtures :all
 
+  def test_invalid_revision
-  def test_revision
     return unless check_repository_testable 
END_DIFF
    @c2 = mock_model Change, 
      :name => 'MV', :path => '/retro/moved_to.rb', :revision => 'R10', :diffable? => false, :from_path => '/retro/moved_from.rb', :from_revision => 'R5'
    @c3 = mock_model Change, 
      :name => 'A', :path => '/retro/added.rb', :revision => 'R10', :diffable? => false
    
    @changeset = mock_model Changeset,
      :revision => 'REV1',
      :short_revision => 'REV1',
      :author => 'dim',
      :log => 'log',
      :created_at => Date.today.to_time,
      :user => nil,
      :changes => [@c1, @c2, @c3]
    assigns[:changeset] = @changeset
    assigns[:next_changeset] = @next_cs = mock_model(Changeset, :revision => 'R15', :to_param => 'R15')
  end

  describe 'in general' do
    before do
      @user.should_receive(:permitted?).with(:code, :browse).and_return(false)
      render '/changesets/show', :helper => 'project_area'
    end

    it 'should display the changeset details' do
      response.should have_tag('div.changeset') do
        with_tag('h3', /REV1/)
        with_tag('h6', 'dim')
      end
    end
    
    it 'should display changeset navigation' do
      response.should have_tag('div.content-header') do
        with_tag 'a[href=?]', project_changesets_path(@project)
        with_tag 'a[href=?]', project_changeset_path(@project, @next_cs)
      end
    end    
  end

  describe 'if user has NO permisssion to see code' do
    before do
      @user.should_receive(:permitted?).with(:code, :browse).and_return(false)
      render '/changesets/show', :helper => 'project_area'
    end

    it 'should not display changes' do
      response.should_not have_tag('ul.changes')
    end    

    it 'should not display the quick diffs' do
      response.should_not have_tag('table.code')
    end    
  end
  
  
  describe 'if user HAS permisssion to see code' do
    
    before do
      @user.stub!(:permitted?).and_return(true)
      @user.stub!(:has_access?).and_return(true)
      @c1.stub!(:previous_revision).and_return('R5')      
      @project.stub!(:relativize_path).with('/retro/modified.rb').and_return('modified.rb')
      @project.stub!(:relativize_path).with('/retro/moved_from.rb').and_return('moved_from.rb')
      @project.stub!(:relativize_path).with('/retro/moved_to.rb').and_return('moved_to.rb')
      @project.stub!(:relativize_path).with('/retro/added.rb').and_return('added.rb')      

    end

    def do_show
      render '/changesets/show', :helper => 'project_area'
    end

    it 'should relativize all absolute paths for display' do      
      @project.should_receive(:relativize_path).with('/retro/modified.rb').exactly(4).times.and_return('modified.rb')
      @project.should_receive(:relativize_path).with('/retro/moved_from.rb').and_return('moved_from.rb')
      @project.should_receive(:relativize_path).with('/retro/moved_to.rb').and_return('moved_to.rb')
      @project.should_receive(:relativize_path).with('/retro/added.rb').and_return('added.rb')      
      do_show
    end

    it 'should check for permissions and access' do
      @user.should_receive(:permitted?).with(:code, :browse).exactly(4).and_return(true)
      do_show
    end
    
    it 'should display changes' do
      do_show
      response.should have_tag('ul.changes li') do
        with_tag "li#ch_info_#{@c1.id}" do
          with_tag 'a[href=?]', project_browse_path(@project, 'modified.rb', :rev => 'R10'), 'modified.rb'
          with_tag 'span a', 'Quick Diff'
        end
        with_tag "li#ch_info_#{@c2.id}" do
          with_tag 'a[href=?]', project_browse_path(@project, 'moved_to.rb', :rev => 'R10'), 'moved_to.rb'
          with_tag 'span a[href=?]', project_browse_path(@project, 'moved_from.rb', :rev => 'R5'), 'moved_from.rb [R5]'
          without_tag 'span a', 'Quick Diff'
        end
        with_tag "li#ch_info_#{@c3.id}" do
          with_tag 'a[href=?]', project_browse_path(@project, 'added.rb', :rev => 'R10'), 'added.rb'
          without_tag 'span a', 'Quick Diff'
        end
      end
    end    

    it 'should have a quick diff for modified files and offer a link to download it' do
      do_show
      response.should have_tag("h3#ch#{@c1.id}") do
        with_tag 'span a[href=?]', "/projects/#{@project.id}/diff/modified.rb?compare_with=R5&amp;format=plain&amp;rev=R10", 'Download Diff'
      end
    end    
  
    it 'should show the side-by-side diff' do
      do_show
      response.should have_tag('table.code') do
        with_tag 'thead' do
          with_tag 'th[colspan=2] a[href=?]', project_browse_path(@project, 'modified.rb', :rev => 'R5'),  'R5'
          with_tag 'th[colspan=2] a[href=?]', project_browse_path(@project, 'modified.rb', :rev => 'R10'), 'R10'          
        end
        with_tag 'tbody.copy', 2
        with_tag 'tbody.update', 1 do
          with_tag 'tr', 1
        end
      end
      response.should have_tag('a', 'Back to top')
    end    
  end
  
end