require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FormatHelper do
  before do
    @project = stub_current_project! :existing_wiki_page_titles => ['Wiki'], :existing_revisions => []
    @user = stub_current_user! :permitted? => true
    helper.stub!(:permitted?).and_return(true)
  end

  describe 'formatting internal links' do

    def do_format(value, options = {})
      helper.send(:format_internal_links, value, options)
    end    

    it 'should still correctly work with changesets' do
      helper.should_receive(:format_internal_changeset_link).exactly(3).times.and_return('LINK')
      do_format('a text with multiple [1a2b] [r1a2] [1a2b] references').should == 'a text with multiple LINK LINK LINK references'
    end

    it 'should still work correctly with tickets' do
      helper.should_receive(:format_internal_ticket_link).with(1234, {}).and_return('LINK')
      do_format('a text with a [#1234] ticket reference').should == 'a text with a LINK ticket reference'
    end      

    it 'should still format line breaks correctly' do
      do_format('a text with a [[BR]] line break').should == 'a text with a <br /> line break'
    end      

    describe 'if text if wiki-page name is less than 2 characters long' do
      
      it 'should keep reference as it is (not a wiki page)' do
        do_format('a short [[W]] reference').should == "a short [[W]] reference"
      end      

    end

    describe 'if demo option is selected' do
      
      describe 'for text links' do
      
        it 'should create a dummy link' do
          do_format('a text with a [[Wiki]] page reference', :demo => true).should == "a text with a <a href=\"#\" onclick=\"; return false;\">Wiki</a> page reference"
        end      
  
      end

      describe 'for image links' do

        it 'should create a dummy image link' do
          do_format('a text with a [[I:Wiki]] image reference', :demo => true).should == %Q(a text with a <img alt="Wiki" src="http://retrospectiva.org/images/logo_small.png" /> image reference)
        end      

        it 'should include the size if present' do
          do_format("Resized image:<br/> [[I:Logo:Optional Alt Text:45x7]]", :demo => true).should == %Q(Resized image:<br/> <img alt="Optional Alt Text" height="7" src="http://retrospectiva.org/images/logo_small.png" width="45" />)
        end      

        it 'should accept html-escaped size if present' do
          do_format("Resized image:<br/> [[I:Logo:Optional Alt Text:45&#215;7]]", :demo => true).should == %Q(Resized image:<br/> <img alt="Optional Alt Text" height="7" src="http://retrospectiva.org/images/logo_small.png" width="45" />)
        end      

      end
    end

    describe 'if text contains a file reference' do
      before do 
        @file = mock_model(WikiFile, :format? => true, :format => 'odf', :file_name => 'document', :to_param => 'Wiki')
        @files = [@file]
        @files.stub!(:find_readable).and_return(@file)
        @project.stub!(:wiki_files).and_return(@files)
      end
      
      it 'should check user permission' do
        helper.should_receive(:permitted?).with(:wiki_pages, :view)
        do_format('a text with a [[F:Wiki]] file reference')
      end           

      it 'should check if file is present' do
        @files.stub!(:find_readable).with('Wiki').and_return(@file)
        do_format('a text with a [[F:Wiki]] file reference')
      end           

      it 'should create a download link' do
        helper.should_receive(:permitted?).with(:wiki_pages, :view)
        do_format('a text with a [[F:Wiki]] file reference').should == "a text with a <a href=\"/projects/#{@project.id}/wiki_files/Wiki.odf\" class=\"download\" title=\"document\">Wiki</a> file reference"
      end           

    end

    describe 'if text contains a image reference' do
      before do 
        @file = mock_model(WikiFile, :format? => true, :format => 'gif', :file_name => 'image', :to_param => 'Wiki')
        @files = [@file]
        @files.stub!(:find_readable_image).and_return(@file)
        @project.stub!(:wiki_files).and_return(@files)
      end
      
      it 'should check user permission' do
        helper.should_receive(:permitted?).with(:wiki_pages, :view)
        do_format('a text with a [[I:Wiki]] file reference')
      end           

      it 'should check if file is present' do
        @files.stub!(:find_readable_image).with('Wiki').and_return(@file)
        do_format('a text with a [[I:Wiki]] image reference')
      end           

      it 'should create a download link' do
        helper.should_receive(:permitted?).with(:wiki_pages, :view)
        do_format('a text with a [[I:Wiki]] image reference').should == "a text with a <img alt=\"Wiki\" src=\"/projects/#{@project.id}/wiki_files/Wiki.gif\" /> image reference"
      end           

      it 'should include the size if present' do
        helper.should_receive(:permitted?).with(:wiki_pages, :view)
        do_format('a text with a [[I:Wiki:300x250]] image reference').should == %Q(a text with a <img alt="Wiki" height="250" src="/projects/#{@project.id}/wiki_files/Wiki.gif" width="300" /> image reference)
      end      

      it 'should accept html-escaped size if present' do
        helper.should_receive(:permitted?).with(:wiki_pages, :view)
        do_format('a text with a [[I:Wiki:300&#215;250]] image reference').should == %Q(a text with a <img alt="Wiki" height="250" src="/projects/#{@project.id}/wiki_files/Wiki.gif" width="300" /> image reference)
      end      

    end

    describe 'if text contains a linkable wiki-page' do
      
      it 'should link the page' do
        @project.should_receive(:existing_wiki_page_titles).and_return(['Wiki'])        
        do_format('a text with a [[Wiki]] page reference').should == "a text with a <a href=\"/projects/#{@project.id}/wiki/Wiki\">Wiki</a> page reference"
      end      

    end

    describe 'if text contains non-existing wiki-page' do

      it 'should check user permission for creating/updating wiki-pages' do
        helper.should_receive(:permitted?).with(:wiki_pages, :update).and_return(true)
        do_format('a text with a [[New]] page reference')
      end           
      
      it 'should show a link to create the page' do
        do_format('a text with a [[New]] page reference').should == "a text with a <span class=\"highlight\">New<a href=\"/projects/#{@project.id}/wiki/New/edit\">?</a></span> page reference"
      end      

    end

    describe 'if nothing applies' do

      it 'should display the reference as pure text (without brackets)' do
        helper.should_receive(:permitted?).with(:wiki_pages, :update).and_return(false)
        do_format('a text with a [[New]] page reference').should == "a text with a New page reference"
      end           
      
    end


  end
end