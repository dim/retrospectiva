require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ChangesetsHelper do
  fixtures :changesets, :changes, :repositories
  
  before do
    helper.stub!(:relativize_path).and_return {|path| path }
    helper.stub!(:link_to_show_file).and_return {|change, *args| change ? change.path : nil }
    helper.stub!(:link_to_quick_diff).and_return {|changeset, change| %Q(<a href="DIFF">#{change.path}</a>) }    
  end
  
  describe 'format changes' do
    before { helper.stub!(:permitted?).and_return(true) }
    
    def format(name)
      helper.format_changes(changesets(name))
    end
    
    describe 'in general' do
      
      it 'should list added files' do
        format(:git_with_added).should have_tag('li', 2)
      end

      it 'should list deleted files' do
        format(:git_with_deleted).should have_tag('li', 2)
      end

      it 'should list renamed files' do
        format(:git_with_renamed).should have_tag('li', 2)
      end

      it 'should list copied files' do
        format(:git_large_copy).should have_tag('li', 21)
      end

      it 'should list submodule entries' do
        format(:git_submodule).should have_tag('li', 2)
      end
      
    end  

    describe 'with browse permission' do

      it 'should list modified files with links' do
        format(:git_with_modified).should have_tag('li', 2) do
          with_tag 'a', 2
        end
      end

    end

    describe 'without browse permission' do
      before { helper.stub!(:permitted?).and_return(false) }
      
      it 'should list modified files without links' do
        format(:git_with_modified).should have_tag('li', 2) do
          without_tag 'a'
        end
      end
    end
    
  end
  
end
