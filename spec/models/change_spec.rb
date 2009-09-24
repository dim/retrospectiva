require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ::Change do
  before(:each) do
    @change = ::Change.new
  end

  it 'should belong to a changeset' do
    @change.should belong_to(:changeset)
  end

  it 'should belong to a repository' do
    @change.should belong_to(:repository)
  end
  
  describe 'when saved' do
    fixtures :changesets, :repositories

    it 'should validate correctness of name' do
      @change.name = 'AB'
      @change.should have(1).error_on(:name)
    end
    
    it 'should validate presence of revision' do
      @change.should validate_presence_of(:revision)
    end    
    
    it 'should inherit the repository-association from the associated changeset' do
      @change.changeset = changesets(:with_binary)
      @change.valid?
      @change.repository.should == repositories(:svn)      
    end

    it 'should inherit the revision from the associated changeset' do
      @change.changeset = changesets(:with_binary)
      @change.valid?
      @change.revision.should == '8'
    end
    
  end

  describe 'an instance' do
    fixtures :changes, :changesets, :repositories
    
    it 'should be able to identify the previous revision' do
      changes(:git_573ae4_m02).previous_revision.should == '9d1574324929aea0eaf446ff23ddcca6d2d236a4'
    end

    it 'should be able to generate a unified DIFF for diffable files' do
      changes(:git_573ae4_m02).unified_diff.
        should == File.read(ActiveSupport::TestCase.fixture_path + '/repository/example_git.diff') 
    end

    it 'should return an empty string as DIFF for non-diffable files' do
      changes(:r03_a02).unified_diff.should == ''
    end
    
    it 'should return an empty string as DIFF if DIFF is exceeding the size limit' do
      Change.stub!(:maximum_diff_size).and_return(0)
      changes(:r04_m02).unified_diff.should == ''
    end    
    
  end
  
  
end
