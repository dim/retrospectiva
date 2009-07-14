require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiPage do
  fixtures :users, :wiki_pages, :wiki_versions, :projects

  describe 'in general' do

    before do 
      @page = wiki_pages(:intro)
    end
  
    it 'should belong to a project' do
      @page.should belong_to(:project)
    end

    it 'can belong to a user' do
      @page.should belong_to(:user)
    end
  
    it 'should validate association of project' do
      @page.should validate_association_of(:project)
    end
    
    it 'should validate presence of author' do
      WikiPage.new.should validate_presence_of(:author)
    end
    
    it 'should validate presence of content' do
      @page.should validate_presence_of(:content)
    end
  
    it 'should validate langth of title within 2 and 80 characters' do
      @page.should validate_length_of(:title, :within => (2..80))
    end

    it 'should validate uniqueness of title per project' do
      @page.should validate_uniqueness_of(:title)
    end
  
    it 'should validate correct format of title' do
      @page.title = ' starts with space'
      @page.should have(1).error_on(:title)
      @page.title = '-starts with any other non-word-character'
      @page.should have(1).error_on(:title)
      @page.title = 'starts with a word-character'
      @page.should have(:no).errors_on(:title)
      @page.title = 'contains.dots'
      @page.should have(1).error_on(:title)
      @page.title = 'contains/slashes'
      @page.should have(1).error_on(:title)
      @page.title = 'contains question marks?'
      @page.should have(1).error_on(:title)
      @page.title = 'contains,commas'
      @page.should have(1).error_on(:title)    
    end

    it 'should use the title as parameter name' do
      @page.to_param.should == @page.title
    end
    
    it 'should validate that content was changed on update' do
      @page.should have(1).error_on(:base)
    end    

    it 'should never have newer versions' do
      @page.newer_versions.should == 0
    end    

    it 'should have as many older versions as assigned historic versions' do
      @page.older_versions.should == 3
    end
    
  end

  describe 'an updated page' do
    
    it 'should have historic versions' do
      wiki_pages(:intro).should have(3).versions
    end

    it 'should have a number indicating historic versions' do
      wiki_pages(:intro).number.should == 4
    end

    describe 'versions' do
      
      it 'should always be sorted by time of creation' do
        wiki_pages(:intro).versions.map(&:id).should == [1,2,3]
      end
    
    end    
  end

  describe 'a created page' do
    
    it 'should not have any versions' do
      wiki_pages(:new).should have(:no).versions
    end

    it 'should always be number one' do
      wiki_pages(:new).number.should == 1
    end
    
  end

  describe 'when creating a new one' do

    before do
      @project = projects(:retro)
      @page = @project.wiki_pages.new :content => 'Content', :author => 'Me'
      @page.title = 'Another Title'
    end

    it 'should update the page-title cache of the parent project' do
      @project.existing_wiki_page_titles.should == ['Retrospectiva', 'New Page']
      @page.save.should be(true)
      @project.reload.existing_wiki_page_titles.should == ['Retrospectiva', 'New Page', 'Another Title']
    end    
    
  end

  describe 'when deleting' do

    before do
      @project = projects(:retro)
    end
    
    it 'should update the page-title cache of the parent project' do
      @project.existing_wiki_page_titles.should == ['Retrospectiva', 'New Page']
      wiki_pages(:new).destroy.should_not be(false)
      @project.reload.existing_wiki_page_titles.should == ['Retrospectiva']
    end    
    
  end
  
  
  describe 'when saving' do
    
    before do
      @page = wiki_pages(:new)
    end
  
    it 'should automatically assign the logged in-user' do
      @page.valid?
      @page.user_id.should be_nil      
      User.stub!(:current).and_return(users(:agent))
      @page.valid?
      @page.user_id.should == 3      
    end

    it 'should automatically set the author field if user is assigned' do
      User.stub!(:current).and_return(users(:agent))
      @page.valid?
      @page.author.should == 'Agent'      
    end
    
    describe 'if the content has changed' do
      
      before { @page.content = 'New Content' }
      
      it 'should store the old version' do
        @page.should have(:no).versions
        @page.save.should be(true)
        @page.should have(1).versions
      end
      
    end

    describe 'if the content has NOT changed' do
      before { @page.title = 'New Title' }

      it 'should override the old version' do
        @page.should have(:no).versions
        @page.save.should be(true)
        @page.should have(:no).versions
      end
      
    end

    describe 'if the title has changed' do
      
      before do
        @project = projects(:retro)
        @page.title = 'Renamed'
      end
      
      it 'should store the old version' do
        @project.existing_wiki_page_titles.should == ['Retrospectiva', 'New Page']
        @page.save.should be(true)
        @project.reload.existing_wiki_page_titles.should == ['Retrospectiva', 'Renamed']
      end
      
    end
        
  end

  describe 'the class' do

    describe 'full text search' do

      it 'should find records matching the milestone name and description' do
        WikiPage.full_text_search('content').should have(2).records
        WikiPage.full_text_search('latest').should have(1).record
      end

    end

    describe 'previewable' do

      describe 'channel' do
        before do
          @channel = WikiPage.previewable.channel(:project => projects(:retro))
        end

        it 'should have correct attributes' do
          @channel.name.should == 'wiki'
          @channel.title.should == 'Wiki'
          @channel.description.should == 'Wiki for Retrospectiva'
          @channel.link.should == 'http://test.host/projects/retrospectiva/wiki'
        end

      end

      describe 'items' do

        before do
          @wiki_page = wiki_pages(:intro)
          @item = @wiki_page.previewable(:project => projects(:retro))
        end

        it 'should have correct attributes' do
          @item.title.should == @wiki_page.title
          @item.description.should == @wiki_page.content
          @item.link.should == "http://test.host/projects/retrospectiva/wiki/Intro"
          @item.date.should == @wiki_page.updated_at
        end

      end

    end
  end
  
  
end