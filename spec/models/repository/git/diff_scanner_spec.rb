require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Repository::Git::DiffScanner do

  describe 'general test' do

    before do
      @content = File.read(RAILS_ROOT + '/spec/fixtures/repository/example_git.diff')
      @scanner = Repository::Git::DiffScanner.new @content
    end
    
    describe 'header' do
      
      it 'should corectly extract source revision' do
        @scanner.source_rev.should == '9d1574324929aea0eaf446ff23ddcca6d2d236a4'
      end
  
      it 'should corectly extract target revision' do
        @scanner.target_rev.should == '573ae4e2c35ca993aef864adac5cdd3e3cf50125'
      end
      
    end
  
    describe 'diff blocks' do
      
      it 'should correctly extract diff blocks and segments' do
        @scanner.blocks.should have(1).record
        @scanner.blocks[0].segments.should have(1).record
      end

      it 'should correctly identify segments' do
        segments = @scanner.blocks[0].segments
        segments[0].should be_instance_of(Repository::Abstract::DiffScanner::Update) 
      end
      
    end

    describe 'each block' do
      
      it 'should be convertable to single-column line-sets' do        
        @scanner.blocks[0].lines.should have(1).records
        @scanner.blocks[0].lines.flatten.should have(12).records
      end

      it 'should be convertable to side-by-side line-sets' do
        @scanner.blocks[0].line_pairs.should have(1).record
      end
      
    end

  end

end

