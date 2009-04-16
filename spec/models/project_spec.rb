require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  fixtures :projects, :groups_projects, :groups, :changesets_projects, :changesets, 
    :milestones, :tickets, :ticket_changes, :repositories, :ticket_property_types, :ticket_properties, :users

  describe 'in general' do
    before(:each) do
      @project = projects(:retro)
    end

    it "should have and belong to many groups" do
      @project.should have_and_belong_to_many(:groups)
      @project.groups.should have(3).record
    end

    it "should have and belong to many changesets" do
      @project.should have_and_belong_to_many(:changesets)
      @project.changesets.should have(10).records
    end

    it "should have many milestones" do
      @project.should have_many(:milestones)
      @project.milestones.should have(3).records
    end

    it "should have many ticket property types" do
      @project.should have_many(:ticket_property_types)
      @project.ticket_property_types.should have(2).records
    end

    it "should have many ticket properties (through ticket property types)" do
      @project.should have_many(:ticket_properties)
      @project.ticket_properties.should have(4).records
    end

    it "should have many ticket reports" do
      @project.should have_many(:ticket_reports)
      @project.ticket_reports.should have(:no).records
    end

    it "should have many tickets" do
      @project.should have_many(:tickets)
      @project.tickets.should have(6).records
    end

    it "should have many ticket changes" do
      @project.should have_many(:ticket_changes)
      @project.ticket_changes.should have(6).records
    end

    it "can belong to repository" do
      @project.should belong_to(:repository)
      @project.repository.should_not be_nil
    end

    it "should return the short name as param" do
      @project.to_param.should == @project.short_name
    end
  
  end
  
  describe 'accessors' do
    
    it 'should cache existing ticket labels' do
      Project.new.existing_tickets.should == {}
    end

    it 'should cache existing revisions labels' do
      Project.new.existing_revisions.should == []
    end

    it 'should have a list of enabled modules' do
      Project.new.enabled_modules.should == []
    end

    it 'should have a list of enabled menu items' do
      Project.new.enabled_menu_items.should_not be_empty
    end
    
  end
  
  describe 'converting paths' do
    
    describe 'if project is in a sub-folder of the repository' do
      
      it 'should be able to absolutize a path' do
        projects(:retro).absolutize_path('app/models').should == 'retrospectiva/app/models'
      end
  
      it 'should be able to relativize a path' do
        projects(:retro).relativize_path('retrospectiva/app/models').should == 'app/models'
      end
      
    end

    describe 'if project is in a root-folder of the repository' do
      
      before do
        @project = Project.new
        @project.stub!(:root_path).and_return(nil)
      end
      
      it 'should be able to absolutize a path' do
        @project.absolutize_path('app/models').should == 'app/models'
      end

      it 'should be able to relativize a path' do
        @project.relativize_path('retrospectiva/app/models').should == 'retrospectiva/app/models'
      end
      
    end
    
  end
  
  describe 'normalizing the root-path' do    
    before(:each) do
      @project = Project.new
    end

    it "should be nil if blank" do
      @project.root_path = '  '
      @project.normalize_root_path!.should == nil
      @project.root_path = ''
      @project.normalize_root_path!.should == nil
      @project.root_path = nil
      @project.normalize_root_path!.should == nil
    end

    it "should remove slashes in the beginning and in the end" do
      @project.root_path = '//home/test//'
      @project.normalize_root_path!.should == 'home/test/'    
    end

    it "should allays append a slash in the end" do
      @project.root_path = 'home/test'
      @project.normalize_root_path!.should == 'home/test/'    
      @project.root_path = 'test'
      @project.normalize_root_path!.should == 'test/'
    end    
  end
  
  describe 'on save' do
    before do
      @project = Project.new      
    end

    it "should validate presence of name" do
      @project.should validate_presence_of(:name)
    end

    it "should validate length of name (2-80 characters)" do
      @project.should validate_length_of(:name, :within => 2..80)
    end

    it "should validate format of name (must at least begin with a latin character)" do
      @project.name = '@Home'
      @project.should have(1).error_on(:name)
    end

    it "should validate uniqueness of name" do
      @project.should validate_uniqueness_of(:name)
    end

    it "should validate format of root path" do
      @project.root_path = 'home\test'
      @project.should have(1).error_on(:root_path)        
      @project.root_path = 'home:test/'
      @project.should have(1).error_on(:root_path)        
    end

    it "should validate the selected locale" do
      @project.locale = 'zz_ZZ'
      @project.should have(1).error_on(:locale)
    end

    it "should nullify locales if none selected" do
      @project.locale = ' '
      @project.should have(:no).error_on(:locale)
      @project.locale.should be_nil
    end

    it "should validate that project is not closed if 'central' is selected" do
      @project.central = @project.closed = true
      @project.should have(1).error_on(:central)
      @project.closed = false
      @project.should have(:no).errors_on(:central)
    end

    it "should validate uniqueness of short-name" do
      @project.name = projects(:retro).name + '***'
      @project.name.should_not == projects(:retro).name
      @project.should have(1).error_on(:name)
      @project.errors.on(:name).should match(/overlap/)
    end

    it "should normalize root path" do
      @project.root_path = '//home/test//'
      @project.valid?
      @project.root_path.should == 'home/test/'
    end

    it "should create/update the short-name" do
      @project.short_name.should be_blank
      @project.name = 'My.:|:.Test.:|:.Project.:.'
      @project.valid?
      @project.short_name.should == 'my-test-project'
    end

    describe 'if project is central' do
      it "should automatically reset the currently selected central project" do
        Project.should_receive(:central=).with(projects(:retro))        
        projects(:retro).central = true
        projects(:retro).save.should be(true)
      end
    end

  end

  describe 'on create' do    
    before do
      @project = Project.new :name => 'New Project', :repository_id => 1            
    end

    it "should automatically associate the default group with this project" do
      @project.save!
      @project.groups.should include(groups(:Default))
    end

    it "should automatically associate all groups with access to all projects" do
      @project.save!
      @project.groups.should include(groups(:all_projects))
    end

    describe 'if the project is open' do
      it "should automatically associate matching changesets" do
        @project.closed = false
        Changeset.should_receive(:update_project_associations!)
        @project.save!
      end
    end

    describe 'if the project is closed' do
      it "should NOT associate changesets" do
        @project.closed = true
        Changeset.should_not_receive(:update_project_associations!)
        @project.save!
      end
    end

    describe 'if the project is central' do
      before do 
        projects(:retro).update_attribute(:central, true)
      end
      
      it "should automatically reset central status of all other projects" do
        Project.find_all_by_central(true).should == [projects(:retro)]
        @project.central = true
        @project.save.should be(true)
        Project.find_all_by_central(true).should == [@project]        
      end
    end

  end

  describe 'on update' do
    describe 'if the project is closed' do
      it "should always drop all changeset associations" do
        projects(:closed).changesets.should_receive(:clear)
        projects(:closed).save.should be(true)
      end      
    end

    describe 'if the project is open' do
      describe 'if the project was closed before' do
        it "should renew changeset associations" do
          projects(:closed).changesets.should_receive(:clear)
          Changeset.should_receive(:update_project_associations!)
          projects(:closed).closed = false
          projects(:closed).save.should be(true)
        end
      end

      describe 'if the root path has changed' do    
        it "should renew changeset associations" do
          projects(:retro).changesets.should_receive(:clear)
          Changeset.should_receive(:update_project_associations!)
          projects(:retro).root_path = 'other_path/'
          projects(:retro).save.should be(true)
        end
      end

      describe 'if the root path has not changed' do
        it "should keep the changeset associations the way they are" do
          projects(:retro).changesets.should_not_receive(:clear)
          Changeset.should_not_receive(:update_project_associations!)
          projects(:retro).save.should be(true)
        end
      end  

      describe 'if the project becomes central' do
        before do 
          projects(:sub).update_attribute(:central, true)
        end
        
        it "should automatically reset central status of all other projects" do
          Project.find_all_by_central(true).should == [projects(:sub)]
          projects(:retro).central = true
          projects(:retro).save.should be(true)
          Project.find_all_by_central(true).should == [projects(:retro)]        
        end
      end

    end
  end

end

