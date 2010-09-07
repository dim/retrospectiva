require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FormatHelper do
  before do
    @project = stub_current_project!
    @user = stub_current_user!
  end
  
  describe 'formatting internal links' do
    def do_format(value)
      helper.send(:format_internal_links, value)
    end    
    
    describe 'for changeset references' do
      before do
        helper.should_not_receive(:format_internal_ticket_link)
      end

      it 'should correctly work without prefixes' do
        helper.should_receive(:format_internal_changeset_link).with('1a2b3c4d', {}).and_return('LINK')
        do_format('a text with a [1a2b3c4d] changeset reference').should == 'a text with a LINK changeset reference'
      end      

      it 'should correctly work without an \'r\' prefix' do
        helper.should_receive(:format_internal_changeset_link).with('1a2b3c4d', {}).and_return('LINK')
        do_format('a text with a [r1a2b3c4d] changeset reference').should == 'a text with a LINK changeset reference'
      end

      it 'should correctly work with multiple references' do
        helper.should_receive(:format_internal_changeset_link).exactly(3).times.and_return('LINK')
        do_format('a text with multiple [1a2b] [r1a2] [1a2b] references').should == 'a text with multiple LINK LINK LINK references'
      end

      it 'should correctly references located at the beginning/end of the document' do
        helper.should_receive(:format_internal_changeset_link).exactly(3).times.and_return('LINK')
        do_format('[1a2b] a text with multiple [r1a2] references [1a2b]').should == 'LINK a text with multiple LINK references LINK'
      end


      it 'should support numeric references' do
        helper.should_receive(:format_internal_changeset_link).with('123', {}).twice.and_return('LINK')
        do_format('a text with a [123] changeset reference').should == 'a text with a LINK changeset reference'
        do_format('a text with a [r123] changeset reference').should == 'a text with a LINK changeset reference'
      end

      it 'should not link escaped references' do
        helper.should_not_receive(:format_internal_changeset_link)
        do_format('a text with a [\123] changeset reference').should == 'a text with a [123] changeset reference'
        do_format('a text with a [\abcd] changeset reference').should == 'a text with a [abcd] changeset reference'
        do_format('a text with a [\r123] changeset reference').should == 'a text with a [r123] changeset reference'
        do_format('a text with a [\rabcd] changeset reference').should == 'a text with a [rabcd] changeset reference'
      end
    end

    describe 'for ticket references' do
      before do
        helper.should_not_receive(:format_internal_changeset_link)
      end

      def do_format(value)
        helper.send(:format_internal_links, value)
      end
      
      it 'should work correctly' do
        helper.should_receive(:format_internal_ticket_link).with(1234, {}).and_return('LINK')
        do_format('a text with a [#1234] ticket reference').should == 'a text with a LINK ticket reference'
      end      

      it 'should numerify references' do
        helper.should_receive(:format_internal_ticket_link).with(0, {}).and_return('LINK')
        do_format('a text with a [#abcdef] ticket reference').should == 'a text with a LINK ticket reference'
      end      

      it 'should not link escaped references' do
        helper.should_not_receive(:format_internal_changeset_link)
        do_format('a text with a [\#1234] ticket reference').should == 'a text with a [#1234] ticket reference'
      end
    end    
  end

  describe 'formatting changeset links' do
    before do
      @user.stub!(:permitted?).and_return true
      @project.stub!(:existing_revisions).and_return ['1a2b3c4d']
    end
    
    def do_format(value, options = {})
      helper.send(:format_internal_changeset_link, value, options)
    end
    
    it 'should just return a dummy link if in demo mode' do
      @user.should_not_receive(:permitted?)
      helper.should_not_receive(:project_changeset_path)
      do_format('1a2b3c4d', :demo => true).should == '<a href="#" onclick="; return false;">[1a2b3c4d]</a>'      
    end
    
    it 'should check for user permissions' do
      @user.should_receive(:permitted?).with(:changesets, :view).and_return(false)
      do_format('1a2b3c4d').should == '[1a2b3c4d]'
    end

    it 'should check if the changeset exists' do
      @project.should_receive(:existing_revisions).and_return ['12345678']
      do_format('1a2b3c4d').should == '[1a2b3c4d]'
    end    

    it 'should rerun a link if criteria is met' do
      helper.should_receive(:project_changeset_path).with(@project, '1a2b3c4d', {}).and_return('LINK_PATH')
      do_format('1a2b3c4d').should == '<a href="LINK_PATH" title="Show changeset 1a2b3c4d">[1a2b3c4d]</a>'
    end    
  end

  describe 'formatting ticket links' do
    before do
      helper.stub!(:find_project_for_ticket).and_return(@project)
      @user.stub!(:permitted?).and_return true
      @project.stub!(:existing_tickets).and_return(1234 => {:state => 1, :summary => 'S1'})
    end
    
    def do_format(value, options = {})
      helper.send(:format_internal_ticket_link, value, options)
    end

    it 'should just return a dummy link if in demo mode' do
      @user.should_not_receive(:permitted?)
      helper.should_not_receive(:find_project_for_ticket)
      helper.should_not_receive(:project_ticket_path)
      do_format(1234, :demo => true).should == '<a href="#" onclick="; return false;">[#1234]</a>'      
    end
    
    it 'should check for user permissions' do
      @user.should_receive(:permitted?).with(:tickets, :view).and_return(false)
      do_format(1234).should == '[#1234]'
    end

    it 'should find the project for ticket' do
      helper.should_receive(:find_project_for_ticket).with(1234).and_return(nil)
      do_format(1234).should == '[#1234]'
    end

    it 'should create a ticket with html-class and html-title for ticket if criteria is met' do
      helper.should_receive(:project_ticket_path).with(@project, 1234).and_return('LINK_PATH')
      do_format(1234).should == '<a href="LINK_PATH" class="ticket-open" title="S1">[#1234]</a>'
    end
  end

  describe 'finding project fo a ticket reference' do
    def do_find
      helper.send(:find_project_for_ticket, 1234)
    end

    describe 'if global ticket references are enabled' do
      it 'should search for tickets within all user-accessible projects' do
        RetroCM[:content][:markup].should_receive(:[]).with(:global_ticket_refs).and_return(true)        
        @user.should_receive(:admin?).and_return(true)
        @user.should_receive(:projects).and_return(AssociationProxies::UserProjects.instantiate(@user))
        do_find.should be_nil
      end      
    end
    
    describe 'if global ticket references are disabled' do
      it 'should search for tickets within all user-accessible projects' do
        RetroCM[:content][:markup].should_receive(:[]).with(:global_ticket_refs).and_return(false)
        @user.should_not_receive(:projects)
        @project.should_receive(:existing_tickets).and_return(1234 => {:state => 1, :summary => 'S1'})
        do_find.should == @project
      end
    end
  end

  describe 'markup' do

    it 'should transform content' do
      helper.markup("h1. Title\n\nSome content").should == "<h1>Title</h1>\n<p>Some content</p>"
    end

    it 'should auto-link content' do
      helper.markup("Visit http://retrospectiva.org for more...").
        should == "<p>Visit <a href=\"http://retrospectiva.org\">http://retrospectiva.org</a> for more&#8230;</p>"
    end

    it 'should corretly auto-link in code-blocks' do
      helper.markup(%({{{\n<a href="http://retrospectiva.org/wiki/Retrospectiva" />\n}}})).
        should == %(<pre><code>&lt;a href=&quot;<a href="http://retrospectiva.org/wiki/Retrospectiva">http://retrospectiva.org/wiki/Retrospectiva</a>&quot; /&gt;\n</code></pre>)
      helper.markup(%({{{\n<scheduler>http://retrospectiva.org/wiki/Retrospectiva?a=1&amp;b=2</scheduler>\n}}})).
        should == %(<pre><code>&lt;scheduler&gt;<a href="http://retrospectiva.org/wiki/Retrospectiva?a=1&amp;b=2">http://retrospectiva.org/wiki/Retrospectiva?a=1&amp;b=2</a>&lt;/scheduler&gt;\n</code></pre>)
    end
    

  end

end
