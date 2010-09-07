require File.dirname(__FILE__) + '/../../spec_helper'

describe "/changesets/diff.html.erb" do

  before do 
    @repository = stub_model(Repository::Subversion)
    @project = stub_model Project, :repository => @repository, :existing_revisions => ['R5', 'R15'], :to_param => 'retro', :root_path => 'retro'
    Project.stub!(:current).and_return(@project)
    
    @user = stub_current_user! :permitted? => true, :has_access? => true
    @change = mock_model Change, 
      :name => 'M', :path => '/retro/modified.rb', :revision => 'R10', :previous_revision => 'R5', :diffable? => true,
      :unified_diff? => true,
      :unified_diff => <<END_DIFF
--- Revision R5
+++ Revision R10
@@ -4,6 +4,22 @@
   fixtures :all
 
+  def test_invalid_revision
-  def test_revision
     return unless check_repository_testable 
END_DIFF
    assigns[:change] = @change
  end

  def do_render
    render '/changesets/diff'
  end
    
  it 'should have a quick diff for modified files and offer a link to download it' do
    do_render
    response.should have_tag("div[id=?]", "ch_#{@change.id}") do
      with_tag 'h3'      
      with_tag 'div a[href=?]', "/projects/retro/diff/modified.rb?compare_with=R5&amp;format=plain&amp;rev=R10", 'Download'
      with_tag 'div a', 'Close'
    end
  end
  
  it 'should show the side-by-side diff' do
    do_render
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
  end
  
end