require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectAreaHelper do
  fixtures :projects

  before do 
    @project = projects(:retro)
    Project.stub!(:current).and_return(@project) 
    @user = mock_current_user! :has_access? => true
  end
  
  describe 'linking to changesets' do

    before do
      helper.stub!(:link_to_if_permitted).and_return 'LINK'
      helper.stub!(:project_changeset_path).and_return('URL')
    end

    it 'should check for permissions' do
      helper.should_receive :link_to_if_permitted
      helper.link_to_changeset('LABEL', 'REVISION')
    end

    it 'should generate the correct URL' do
      helper.should_receive(:project_changeset_path).with(@project, 'REVISION').and_return('URL')
      helper.link_to_changeset('LABEL', 'REVISION')
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
