require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Repository::Subversion::Node do
  fixtures :repositories, :changesets
  
  def request_node(path, revision = nil, skip_content = false)
    Repository::Subversion::Node.new(repositories(:svn), path, revision, skip_content)
  end

  describe 'requesting a node' do    
    describe 'with an invalid revision' do
      it 'should raise an Invalid Revision exception' do
        lambda { 
          request_node("retrospectiva/config/environment.rb", 100000) 
        }.should raise_error(Repository::InvalidRevision)
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
          request_node("retrospectiva/script/weird.rb", 5) 
        }.should raise_error(Repository::Abstract::Node::InvalidPath)          
      end
    end
    
    describe 'with valid path and revision' do
      before do
        @node = request_node("retrospectiva/config/environment.rb")
      end
      
      it 'should return a Subversion Node' do
        @node.should be_kind_of(Repository::Subversion::Node)
      end

      it 'should correctly identify the revision' do        
        @node.revision.should == '4'
        @node.revision.should == changesets(:with_modified).revision
      end

      it 'should correctly identify the author' do
        @node.author.should == changesets(:with_modified).author
      end      

      it 'should correctly identify the date of last modification' do
        @node.date.utc.to_i.should == changesets(:with_modified).created_at.utc.to_i
      end      

      it 'should correctly identify the change-log' do
        @node.log.should == changesets(:with_modified).log
      end
      
      it 'should correctly identify properties' do
        @node = request_node("retrospectiva/public/images/rss.png")
        @node.properties.should == {"svn:mime-type"=>"image/png"}
      end

      it 'should correctly identify mime-type' do
        @node = request_node("retrospectiva/public/images/rss.png")
        @node.mime_type.should == MIME::Types['image/png']
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

    it 'should have a content' do
      @node.content.should_not be_blank      
    end

    it 'should be able to skip content' do
      request_node("retrospectiva/config/environment.rb", nil, true).content.should == ''      
    end

    it 'should return the content-length as size' do
      @node.size.should == @node.content.size
    end

    it 'should have a mime-type' do
      @node.mime_type.should == MIME::Types['application/ruby']
    end
  end

  describe 'requesting a directory node' do    
    before do
      @node = request_node("retrospectiva/script", 2)
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
  
end if Repository::Subversion.enabled?
