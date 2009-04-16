require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Changeset do      
  fixtures :changesets, :projects, :users, :repositories, :changesets_projects, :changes
  
  describe 'class' do
    it 'should expire cache on delete-all' do
      Changeset.should_receive(:expire_cache!)
      Changeset.delete_all ['revision = ?', 'not-there']      
    end

    it 'should expire cache on destroy-all' do
      Changeset.should_receive(:expire_cache!)
      Changeset.destroy_all ['revision = ?', 'not-there']
    end    

    it 'should return (by default) up to 5 records per page' do
      Changeset.per_page.should == 5
    end    

    describe 'full text search' do
      fixtures :changesets      
      
      it 'should find records matching commit log' do
        Changeset.full_text_search('binary').should have(4).records
        Changeset.full_text_search('file -binary').should have(14).records
      end

      it 'should find records matching revision' do
        Changeset.full_text_search('1dc200').should == [changesets(:git_with_binary)]
      end
      
    end

    describe 'previewable' do
      
      describe 'channel' do
        before do
          @channel = Changeset.previewable.channel(:project => projects(:retro))
        end
        
        it 'should have a valid name' do
          @channel.name.should == 'changesets'
        end
        
        it 'should have a valid title' do
          @channel.title.should == 'Changesets'
        end
        
        it 'should have a valid description' do
          @channel.description.should == 'Changesets for Retrospectiva'
        end
        
        it 'should have a valid link' do
          @channel.link.should == 'http://test.host/projects/retrospectiva/changesets'
        end      

      end

      describe 'items' do
        before do
          @changeset = changesets(:initial)
          @item = @changeset.previewable(:project => projects(:retro))
        end
        
        it 'should have a valid title' do
          @item.title.should == "Changeset #{@changeset.revision}"
        end
        
        it 'should have a valid description' do
          @item.description.should == @changeset.log
        end
        
        it 'should have a valid link' do
          @item.link.should == "http://test.host/projects/retrospectiva/changesets/#{@changeset.revision}"
        end
        
        it 'should have a date' do
          @item.date.should == @changeset.created_at
        end      
        
      end
      
    end
  end
  
  describe 'instance' do
  
    before(:each) do
      @changeset = changesets(:initial)
    end

    it 'should use revision as param' do
      @changeset.to_param.should == @changeset.revision
    end

    it 'should choose short revision representation from repository type' do
      @changeset.short_revision.should == '1'
      changesets(:git_initial).short_revision.should == 'fda71ed'
    end

    it 'should validate presence of repository ID' do
      @changeset.should validate_presence_of(:repository_id)
    end
  
    it 'should validate presence of revision' do
      @changeset.should validate_presence_of(:revision)
    end
  
    it 'should validate uniqueness of revision accross a repository' do
      @changeset.should validate_presence_of(:revision)
    end
  
    it 'should belong to a repository' do
      @changeset.should belong_to(:repository)
    end
  
    it 'can belong to a user' do
      @changeset.should belong_to(:user)
    end
  
    it 'should have many changes' do
      @changeset.should have_many(:changes)
      @changeset.changes.should have(30).records
    end
  
    it 'should have and belong to many projects' do
      @changeset.should have_and_belong_to_many(:projects)
      @changeset.projects.should have(1).records
    end  

    describe 'browsing' do
      before { @project = projects(:retro) }
      
      it 'should be able to find the next record for a project' do
        changesets(:initial).next_by_project(@project).should == changesets(:with_deleted)
      end  

      it 'should return nil if no next record can be found be for a project' do
        changesets(:prop_set).next_by_project(@project).should be_blank
      end  

      it 'should be able to find the previous record for a project' do
        changesets(:with_deleted).previous_by_project(@project).should == changesets(:initial)
      end  

      it 'should return nil if no next record can be found record for a project' do
        changesets(:initial).previous_by_project(@project).should be_blank
      end  
    end

    describe 'changeset-project synchronisation' do
      describe 'if a project has a root-path prefix' do
        before do 
          @project = projects(:retro)
          @project.changesets.clear
          @project.changesets.should have(:no).records      
        end
        
        it 'should correctly find and assign all changesets withing the root-path scope' do
          Changeset.update_project_associations!
          @project.changesets.reload.should have(10).records
          @project.changesets.map(&:revision).map(&:to_i).sort.should == ((1..11).to_a - [10])
        end
      end
  
      describe 'if a project has not root-path prefix' do
        before do 
          @project = projects(:closed)
          @project.closed = false
          @project.save.should be(true)
          @count_all = Changeset.count(:all, :conditions => {:repository_id => @project.repository_id})
        end
        
        it 'should find and assign all changesets for the matching repository' do
          Changeset.update_project_associations!
          @project.changesets.should have(@count_all).records      
        end
      end
  
      describe 'if a project is closed' do
        before do 
          @project = projects(:closed)
          @project.changesets.should have(:no).records      
        end
        
        it 'should not find any changesets' do
          Changeset.update_project_associations!
          @project.changesets.reload.should have(:no).records      
        end
      end  
    end
    
  end

  describe 'on create' do
  
    before(:each) do
      @changeset = Changeset.new :revision => '800', :repository_id => 1
      @changeset.changes.build :name => 'M', :path => 'retrospectiva/file.rb'
    end

    it 'should create changeset-project relation' do
      @changeset.save.should be(true)   
      @changeset.projects.should == [projects(:retro)]
    end
    
    it 'should update the existing-revisions cache in parent project' do
      projects(:retro).existing_revisions.should_not include('800')
      @changeset.save.should be(true)   
      projects(:retro).reload.existing_revisions.should include('800')
    end

    describe 'if in bulk-mode' do

      it 'should NOT create changeset-project relation' do
        @changeset.bulk_synchronization = true
        @changeset.save.should be(true)   
        @changeset.projects.should == []
      end
      
      it 'should update the existing-revisions cache in parent project' do
        @changeset.bulk_synchronization = true
        projects(:retro).existing_revisions.should_not include('800')
        @changeset.save.should be(true)   
        projects(:retro).reload.existing_revisions.should_not include('800')
      end      
      
    end
    
    describe 'if a valid user matches the changeset author' do
      it 'should assign the user to the changeset' do
        @changeset.author = users(:agent).scm_name
        @changeset.save.should be(true)
        @changeset.user(true).should == users(:agent)
      end
    end

    describe 'if an inactive user matches the changeset author' do
      it 'should not assign the user to the changeset' do
        @changeset.author = users(:inactive).scm_name
        @changeset.save.should be(true)
        @changeset.user.should be_nil
      end
    end

    describe 'if no user matches the changeset author' do
      it 'should not assign any user to the changeset' do
        @changeset.author = 'not-existing-user'
        @changeset.save.should be(true)
        @changeset.user.should be_nil
      end
    end  

  end


  describe 'on delete' do

    before do
      @project = projects(:retro)
      @changeset = changesets(:with_added)
    end

    it 'should remove the revision reference from the existing-revisions cache in parent project' do
      @project.existing_revisions.should include(@changeset.revision)      
      @changeset.destroy
      @project.reload.existing_revisions.should_not include(@changeset.revision)      
    end
    
  end
end
