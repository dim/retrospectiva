require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Repository::Git do
  fixtures :repositories, :changesets, :changes, :projects, :changesets_projects
  before do
    @repository = repositories(:git)    
  end

  describe 'bulk synchronization' do
    before(:each) do
      @should = @repository.changesets.find :all, :include => [:changes]
    end

    def do_sync
      @repository.changesets.destroy_all  
      @repository.changesets.should have(:no).records
      @repository.sync_changesets
      @repository.changesets.reload      
    end
    
    def list_of(changes, attribute)
      changes.sort_by(&:path).map(&attribute.to_sym) 
    end
    
    it 'should perform correctly (all in one test for performance reasons)' do
      do_sync

      # should create a list of changesets in the database
      @repository.changesets.should have(@should.size).records
            
      @should.each do |original|
        synchronised = @repository.changesets.find_by_revision!(original.revision)

        # should be an new record
        synchronised.id.should_not == original.id

        # should have the expected attributes
        synchronised.log.should == original.log
        synchronised.author.should == original.author

        # should be associated with the right project(s)
        synchronised.projects.should == []
        
        # should have changes (as expected)
        list_of(synchronised.changes, :path).should == list_of(original.changes, :path)
        list_of(synchronised.changes, :from_path).should == list_of(original.changes, :from_path)
        list_of(synchronised.changes, :from_revision).should == list_of(original.changes, :from_revision)
        list_of(synchronised.changes, :name).should == list_of(original.changes, :name)
      end
    end
    
  end

  describe 'it the repository is set-up correctly' do
    
    it 'should be active' do
      @repository.should be_active
    end
    
  end

  describe 'it the repository path is not pinting to a valid repository' do
    
    before do
      @repository.path = RAILS_ROOT + '/app'
    end
    
    it 'should not be active' do        
      @repository.should_not be_active
    end
    
  end
  
  it 'should return the correct diff-scanner' do
    @repository.diff_scanner.should == Repository::Git::DiffScanner
  end
  
  it 'should correctly extract the latest revision' do
    @repository.latest_revision.should == 'fe8566ec42808bdce1795d0759ee1e4a49bd2715'
  end

  describe 'creating a unified diff' do
    describe 'with valid path and between two valid revisions' do
      it 'should return the diff content' do
        udiff = @repository.unified_diff("retrospectiva/script/weird.rb", "9d1574324929aea0eaf446ff23ddcca6d2d236a4", "573ae4e2c35ca993aef864adac5cdd3e3cf50125")
        udiff.size.should == 326
        Digest::SHA1.hexdigest(udiff).should == 'e41b24fc67bcc0c44c9543967e5643fe3dd18221'
      end
    end

    describe 'with invalid revisions' do
      it 'should return an empty string' do
        @repository.unified_diff("retrospectiva/script/weird.rb", "9d1574324929aea0eaf446ff23ddcca6d2d236a4", "1234567890123456789012345678901234567890").should == ''
      end
    end

    describe 'with an undiffable (binary) file' do
      it 'should return an empty string' do
        @repository.unified_diff("retrospectiva/public/images/rss.png", changesets(:git_with_binary).revision, changesets(:git_with_binary_modification).revision).should == ''
      end
    end

    describe 'with a non-existing file' do
      it 'should return an empty string' do
        @repository.unified_diff("nonexistence", "9d1574324929aea0eaf446ff23ddcca6d2d236a4", "1234567890123456789012345678901234567890").should == ''
      end
    end    
  end

  describe 'building a revision history' do
    before(:each) do
      @path = "retrospectiva/config/environment.rb"
    end
    
    it 'should correctly build the history' do
      @repository.history(@path).should == changesets(:git_with_modified, :git_with_added).map(&:revision)
    end    
  end

end if SCM_GIT_ENABLED
