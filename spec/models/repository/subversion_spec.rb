require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Repository::Subversion do
  fixtures :repositories, :changesets, :changes
  before do
    @repository = repositories(:svn)    
  end

  describe 'synchronization' do
    before(:each) do
      @should = @repository.changesets.find(:all, :conditions => ['id < 200'], :include => [:changes])
    end

    def do_sync
      @repository.changesets.destroy_all  
      @repository.changesets.should have(:no).records
      @repository.sync_changesets
      @repository.changesets.reload      
    end
    
    it 'should create a list of changesets in the database' do
      do_sync
      @repository.changesets.should have(@should.size).records
    end

    def list_of(changes, attribute)
      changes.sort_by(&:path).map(&attribute.to_sym) 
    end
    
    it 'should perform correctly' do
      do_sync
      @should.each do |original|
        synchronised = @repository.changesets.find_by_revision(original.revision)
        synchronised.id.should_not == original.id
        synchronised.log.should == original.log
        synchronised.author.should == original.author
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
    @repository.diff_scanner.should == Repository::Subversion::DiffScanner
  end
  
  it 'should correctly extract the latest revision' do
    @repository.latest_revision.should == '10'
  end

  describe 'creating a unified diff' do
    describe 'with valid path and between two valid revisions' do
      it 'should return the diff content' do
        @udiff = @repository.unified_diff("retrospectiva/script/weird.rb", "3", "4")
        @udiff.size.should == 249
        Digest::SHA1.hexdigest(@udiff).should == '90468b1ed23997ba3a58cba65b246685a13fbe2e'
      end
    end

    describe 'with invalid revisions' do
      it 'should return an empty string' do
        @repository.unified_diff("retrospectiva/script/weird.rb", "4", "10000").should == ''
      end
    end

    describe 'with an undiffable (binary) file' do
      it 'should return an empty string' do
        @repository.unified_diff("retrospectiva/public/images/rss.png", "8", "9").should == ''
      end
    end

    describe 'with a non-existing file' do
      it 'should return an empty string' do
        @repository.unified_diff("nonexistence", "1", "2").should == ''
      end
    end    
  end

  describe 'building a revision history' do
    before(:each) do
      @path = "retrospectiva/config/environment.rb"
    end
    
    it 'should correctly build the history' do
      @repository.history(@path).should == ['4', '3']
    end    
  end

end if SCM_SUBVERSION_ENABLED
