require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Repository::Git::Node do
  fixtures :repositories, :changesets
  
  def request_node(path, revision = nil)    
    Repository::Git::Node.new(repositories(:git), path, revision)
  end

  def invalid_revision
    '1234567890123456789012345678901234567890'
  end

  describe 'an instance' do
    
    it 'should return the first 6 characters as short-revision' do
      request_node("retrospectiva/config/environment.rb").short_revision.should == '573ae4e'
    end    
    
  end

  describe 'requesting a node' do    
    describe 'with an invalid revision' do

      it 'should raise an Invalid Revision exception' do
        lambda { 
          request_node("retrospectiva/config/environment.rb", invalid_revision) 
        }.should raise_error(Repository::Abstract::Node::InvalidPathForRevision)
      end

      it 'should raise an Invalid Revision exception' do
        lambda { 
          request_node('', '127') 
        }.should raise_error(Repository::Abstract::Node::InvalidPathForRevision)
      end

    end

    describe 'with an invalid path' do
      it 'should raise an Invalid Path exception' do
        lambda { 
          request_node('nonexistent') 
        }.should raise_error(Repository::Abstract::Node::InvalidPath)

        lambda { 
          request_node("retrospectiva/script/weird.rb") 
        }.should raise_error(Repository::Abstract::Node::InvalidPath)          

        lambda { 
          request_node("retrospectiva/script/weird.rb", invalid_revision) 
        }.should raise_error(Repository::Abstract::Node::InvalidPath)          
      end

    end
    
    describe 'with valid path and revision' do
      before do
        @node = request_node("retrospectiva/config/environment.rb")
      end
      
      it 'should return a Subversion Node' do
        @node.should be_kind_of(Repository::Git::Node)
      end

      it 'should correctly identify the revision' do
        @node.revision.should == '573ae4e2c35ca993aef864adac5cdd3e3cf50125'
        @node.revision.should == changesets(:git_with_modified).revision
      end

      it 'should correctly identify the author' do
        @node.author.should == changesets(:git_with_modified).author
      end      

      it 'should correctly identify the date of last modification' do
        @node.date.should == changesets(:git_with_modified).created_at
        @node.date.should be_kind_of(Time)
      end      

      it 'should correctly identify the change-log' do
        @node.log.should == changesets(:git_with_modified).log
      end
      
      it 'should correctly identify properties' do
        @node = request_node("retrospectiva/public/images/rss.png")
        @node.properties.should == {}
      end

    end        
  end
  
  describe 'requesting a file node' do    
    before do
      @node = request_node("retrospectiva/config/environment.rb")
    end

    it 'should correctly identify the node as a file node' do
      @node.should_not be_dir
    end          

    it 'should not return any sub-nodes' do
      @node.sub_nodes.should == []
    end          

    it 'should have a sub-node-count of zero' do
      @node.sub_node_count == 0
    end

    it 'should have a contnent' do
      @node.content.should_not be_blank      
    end

    it 'should return the content-length as size' do
      @node.size.should == 1797
    end

    it 'should have a mime-type' do
      @node.mime_type.should == MIME::Types['application/ruby']
    end
  end

  describe 'requesting a directory node' do    
    before do
      @node = request_node("retrospectiva/script", '2dfd49e7cde300a492cea81884fdb08be861ad02')
    end

    it 'should correctly identify the node as a directory node' do
      @node.should be_dir
    end          

    it 'should return the sub-nodes' do
      @node.sub_nodes.map(&:path).sort.should == [
        "retrospectiva/script/about",
        "retrospectiva/script/breakpointer",
        "retrospectiva/script/console",
        "retrospectiva/script/destroy",
        "retrospectiva/script/generate",
        "retrospectiva/script/performance",
        "retrospectiva/script/plugin",
        "retrospectiva/script/process",
        "retrospectiva/script/runner",
        "retrospectiva/script/server"]
    end

    it 'should have a sub-node-count' do
      @node.sub_node_count == 10
    end

    it 'should have no content' do
      @node.content.should be_blank      
    end

    it 'should return zero as size' do
      @node.size.should be_zero
    end

    it 'should have no mime-type' do
      @node.mime_type.should be_nil
    end
  end
  
end
