require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Repository::Abstract do
  before(:each) do
    @repository = Repository::Abstract.new :hidden_paths => '
      /retrospectiva/config/data*
      /retrospectiva/config/runtime/*.yml
      
      @@@
    '
  end

  describe 'class methods' do
    
    it 'should return the a short representation of a revision' do
      Repository::Abstract.truncate_revision('1234567890123567890').should == '1234567890123567890'
    end
    
  end
  

  describe 'abstract methods' do
    it 'should have latest_revision' do
      lambda { @repository.latest_revision }.should raise_error(NotImplementedError)            
    end
    it 'should have unified_diff' do
      lambda { @repository.unified_diff(nil, nil, nil) }.should raise_error(NotImplementedError)            
    end
    it 'should have history' do
      lambda { @repository.history(nil, nil) }.should raise_error(NotImplementedError)            
    end
    it 'should have sync_changesets' do
      lambda { @repository.sync_changesets }.should raise_error(NotImplementedError)            
    end
  end

  it 'should correctly extract patterns from hidden-paths content' do
    @repository.send(:hidden_path_patterns).should == [
      "/retrospectiva/config/data*",
      "/retrospectiva/config/runtime/*.yml",
      "@@@"
    ]
  end

  it 'should return the correct diff-scanner' do
    @repository.diff_scanner.should == Repository::Abstract::DiffScanner
  end
  
  it 'should be able to determine is a repository path is visible' do
    @repository.visible_path?('/retrospectiva/config/database.yml').should be(false)
    @repository.visible_path?('/retrospectiva/config/date_base.rb').should be(true)
    @repository.visible_path?('/retrospectiva/config/runtime/tasks.yml').should be(false)
    @repository.visible_path?('/retrospectiva/config/runtime/tasks.xml').should be(true)
  end
end
