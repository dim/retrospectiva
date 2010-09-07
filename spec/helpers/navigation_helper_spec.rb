require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NavigationHelper do
  fixtures :projects

  before do 
    @project = projects(:retro)
    Project.stub!(:current).and_return(@project) 
    @user = stub_current_user! :has_access? => true
  end

  describe 'linking to changesets' do

    before do
      @user.stub!(:permitted?).and_return(true)
      @project.stub!(:existing_revisions).and_return(['REVISION'])
      helper.stub!(:project_changeset_path).and_return('URL')
    end

    it 'should check for permissions' do
      @user.should_receive(:permitted?).with(:changesets, :view).and_return(false)
      helper.link_to_changeset('LABEL', 'REVISION').should == 'LABEL'
    end

    it 'should check if revision exists' do
      @project.should_receive(:existing_revisions).and_return(['OTHER'])
      helper.link_to_changeset('LABEL', 'REVISION').should == 'LABEL'
    end

    it 'should generate the correct URL if conditions are met' do
      helper.should_receive(:project_changeset_path).with(@project, 'REVISION', {}).and_return('URL')
      helper.link_to_changeset('LABEL', 'REVISION').should == '<a href="URL" title="Show changeset REVISION">LABEL</a>'
    end

  end

  describe 'linking browseable paths' do

    it 'should check for permissions, gnerate the correnct URL and add a title to the link' do
      helper.should_receive(:link_to_if_permitted).with('LABEL', "/projects/retrospectiva/browse/folder/file.rb?rev=REVISION", :title => 'Browse folder/file.rb [REVISION]')
      helper.link_to_browse('LABEL', '/folder//file.rb', 'REVISION')
    end

    it 'should call the correct method' do
      helper.should_receive(:project_browse_path).with(@project, ['folder', 'file.rb'], :rev => 'REVISION')
      helper.should_receive(:link_to_if_permitted).and_return 'LINK'
      helper.link_to_browse('LABEL', 'folder/file.rb', 'REVISION')
    end

    it 'should generate correct URLs and revision links' do
      helper.link_to_browse('LABEL', 'folder/file.rb', 'AF03').should ==
        "<a href=\"/projects/retrospectiva/browse/folder/file.rb?rev=AF03\" title=\"Browse folder/file.rb [AF03]\">LABEL</a>"
    end

    it 'should generate correct URLs for string-arguments' do
      helper.link_to_browse('LABEL', 'folder/file.rb').should ==
        "<a href=\"/projects/retrospectiva/browse/folder/file.rb\" title=\"Browse folder/file.rb\">LABEL</a>"
    end

    it 'should generate correct URLs for array-arguments' do
      helper.link_to_browse('LABEL', ['folder', 'file.rb']).should ==
        "<a href=\"/projects/retrospectiva/browse/folder/file.rb\" title=\"Browse folder/file.rb\">LABEL</a>"
    end

    it 'should relativize array URLs' do
      helper.link_to_browse('LABEL', ['retrospectiva', 'folder', 'file.rb']).should ==
        "<a href=\"/projects/retrospectiva/browse/folder/file.rb\" title=\"Browse folder/file.rb\">LABEL</a>"
    end

    it 'should relativize string URLs' do
      helper.link_to_browse('LABEL', 'retrospectiva/folder/file.rb').should == 
        "<a href=\"/projects/retrospectiva/browse/folder/file.rb\" title=\"Browse folder/file.rb\">LABEL</a>"
    end
    
  end
  
end

