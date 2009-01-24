require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Repository do
  before(:each) do
    @repository = Repository.new
  end
  
  it 'should validate presence of name' do
    @repository.should validate_presence_of(:name)
  end

  it 'should validate uniqueness of name' do
    @repository.should validate_uniqueness_of(:name)
  end

  it 'should validate presence of path' do
    @repository.should validate_presence_of(:path)
  end

  it 'should validate uniqueness of path' do
    @repository.should validate_uniqueness_of(:path)
  end

  it 'should validate correct repository-kind' do
    Repository.new.should have(1).error_on(:kind)
    Repository::Abstract.new.should have(1).error_on(:kind)
    Repository::Subversion.new.should have(:no).errors_on(:kind)
    Repository::Git.new.should have(:no).errors_on(:kind)
  end
    
  it 'should have many changesets' do
    @repository.should have_many(:changesets)
  end

  it 'should have many changes' do
    @repository.should have_many(:changes)
  end

  it 'should have many projects' do
    @repository.should have_many(:projects)
  end

  describe 'a new instance' do

    it 'should have a kind' do
      Repository::Subversion.new.kind.should == 'Subversion'
    end
  
  end

  describe 'an existing instance' do
    fixtures :repositories

    it 'should have a kind' do
      repositories(:svn).kind.should == 'Subversion'
    end
  
  end

  describe 'class' do
    
    it 'should find all available types' do
      Repository.types.size.should == Repository::Abstract.subclasses.size
      Repository.types.should include('Subversion')
      Repository.types.should include('Git')
    end

    it 'should return the correct klass for a given type-string' do
      Repository.klass('Subversion').should == Repository::Subversion
      Repository.klass('Git').should == Repository::Git
      Repository.klass('Abstract').should == Repository::Abstract
    end

    it 'should return the correct klass for a given type-symbol' do
      Repository.klass(:subversion).should == Repository::Subversion
      Repository.klass(:git).should == Repository::Git
      Repository.klass(:abstract).should == Repository::Abstract
    end

    it 'should return nil if type is invalid' do
      Repository.klass('Invalid').should be_nil
    end

  end

end
