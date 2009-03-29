require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Repository::Abstract::Node do

  describe 'every instance' do
    before do
      @node = Repository::Abstract::Node.new(Repository::Abstract.new, '')
    end
    
    
    it 'should have a revision (abstract)' do
      lambda { @node.revision }.should raise_error(NotImplementedError)
    end

    it 'should have a short revision (returning the revision)' do
      @node.stub!(:revision).and_return('12345678901234567890') 
      @node.short_revision.should == '12345678901234567890' 
    end

    it 'should have a author (abstract)' do
      lambda { @node.author }.should raise_error(NotImplementedError)
    end

    it 'should have a date (abstract)' do
      lambda { @node.date }.should raise_error(NotImplementedError)
    end

    it 'should have a log (abstract)' do
      lambda { @node.log }.should raise_error(NotImplementedError)
    end

    it 'should have a directory indicator (abstract)' do
      lambda { @node.dir? }.should raise_error(NotImplementedError)
    end

    it 'should have sub-nodes (abstract)' do
      lambda { @node.sub_nodes }.should raise_error(NotImplementedError)
    end

    it 'should have an exists indicator (abstract)' do
      lambda { @node.send :exists? }.should raise_error(NotImplementedError)
    end

    it 'should have no properties by default' do
      @node.properties.should == {} 
    end
    
    describe 'mime-type detection' do
      
      it 'should be nil if node does not exist' do
        @node.should_receive(:exists?).and_return(false)
        @node.mime_type.should be_nil     
      end

      it 'should be nil if node is a directory' do
        @node.should_receive(:exists?).and_return(true)
        @node.should_receive(:dir?).and_return(true)
        @node.mime_type.should be_nil     
      end

      it 'should by default be empty if node is ae existing file' do
        @node.should_receive(:exists?).and_return(true)
        @node.should_receive(:dir?).and_return(false)
        @node.mime_type.should == "application/octet-stream"
      end
      
    end

    
    describe 'content retrieval' do
      
      it 'should be nil if node does not exist' do
        @node.should_receive(:exists?).and_return(false)
        @node.content.should be_nil     
      end

      it 'should be nil if node is a directory' do
        @node.should_receive(:exists?).and_return(true)
        @node.should_receive(:dir?).and_return(true)
        @node.content.should be_nil     
      end

      it 'should by default be empty if node is ae existing file' do
        @node.should_receive(:exists?).and_return(true)
        @node.should_receive(:dir?).and_return(false)
        @node.content.should == ''
      end
      
    end
    
    
    describe 'node name' do
      
      before do
        @node.stub!(:path).and_return('script/server')
      end
      
      it 'should be the file name if the node is a file' do
        @node.should_receive(:dir?).and_return(false)
        @node.name.should == 'server'        
      end

      it 'should be the directory name if the node is a directory' do
        @node.should_receive(:dir?).and_return(true)
        @node.name.should == 'server/'
      end
      
    end

    
    describe 'content type identification' do
      
      before do
        @node.stub!(:dir?).and_return(false)
        @node.stub!(:mime_type).and_return(Repository::Abstract::Node::DEFAULT_MIME_TYPE)
        @node.stub!(:binary?).and_return(false)
      end
      
      it 'should be :dir if node is a directory' do
        @node.should_receive(:dir?).and_return(true)
        @node.content_type.should == :dir
      end

      it 'should be :text if node has a textual mime-type' do
        @node.should_receive(:mime_type).exactly(4).times.and_return(MIME::Types['text/plain'].first)
        @node.content_type.should == :text
      end

      it 'should be :image if node has a web-image mime-type' do
        @node.should_receive(:mime_type).twice.and_return(MIME::Types['image/png'].first)
        @node.content_type.should == :image
      end

      it 'should NOT be :image if node has a non-web-image mime-type' do
        @node.should_receive(:mime_type).twice.and_return(MIME::Types['image/bmp'].first)
        @node.content_type.should == :unknown
      end

      it 'should be :binary if file is binary' do
        @node.should_receive(:binary?).and_return(true)
        @node.content_type.should == :binary
      end

      it 'should be :unknown if unable to determine' do
        @node.content_type.should == :unknown
      end
      
    end
    
    
  end

end

