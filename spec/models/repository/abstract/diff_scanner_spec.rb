require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Repository::Abstract::DiffScanner do

  def segment_types(block)
    block.segments.map do |s|
      s.class.name.demodulize.downcase.to_sym 
    end      
  end

  def segment_infos(block)
    block.segments.map(&:info)
  end


  describe 'general test' do

    before do
      @content = File.read(RAILS_ROOT + '/spec/fixtures/repository/example_svn.diff')
      @scanner = Repository::Abstract::DiffScanner.new @content
    end
    
    describe 'header' do
      
      it 'should corectly extract source revision' do
        @scanner.source_rev.should == '123'
      end
  
      it 'should corectly extract target revision' do
        @scanner.target_rev.should == '456'
      end
      
    end
  
    describe 'diff blocks' do
      
      it 'should correctly extract diff blocks and segments' do
        @scanner.blocks.should have(6).records
        @scanner.blocks[0].segments.should have(7).records
        @scanner.blocks[1].segments.should have(3).records
        @scanner.blocks[2].segments.should have(3).records
        @scanner.blocks[3].segments.should have(3).records
        @scanner.blocks[4].segments.should have(5).records
        @scanner.blocks[5].segments.should have(3).records
      end

      it 'should correctly identify segments' do
        segments = @scanner.blocks[0].segments
        segment_types(@scanner.blocks[0]).should == [:copy, :update, :copy, :update, :copy, :update, :copy]
        segment_infos(@scanner.blocks[0]).should == ['3', '8/0', '5', '1/1', '2', '1/2', '3']
      end
      
    end

    describe 'each block' do
      
      it 'should be convertable to single-column line-sets' do        
        @scanner.blocks[0].lines.should have(7).records
        @scanner.blocks[0].lines.flatten.should have(26).records
        @scanner.blocks[1].lines.should have(3).records
        @scanner.blocks[1].lines.flatten.should have(11).records
        @scanner.blocks[4].lines.should have(5).records
        @scanner.blocks[4].lines.flatten.should have(26).records
        @scanner.blocks[5].lines.should have(3).records
        @scanner.blocks[5].lines.flatten.should have(10).records
      end

      it 'should be convertable to side-by-side line-sets' do        
        @scanner.blocks[0].line_pairs.should have(7).records
        @scanner.blocks[1].line_pairs.should have(3).records
        @scanner.blocks[4].line_pairs.should have(5).records
        @scanner.blocks[5].line_pairs.should have(3).records
      end
      
    end

  end


  describe 'complex block detection' do

    before do
      @content = File.read(RAILS_ROOT + '/spec/fixtures/repository/example_block.diff')
      @scanner = Repository::Abstract::DiffScanner.new @content
    end
    
    it 'should correctly extract diff blocks and segments' do
      @scanner.blocks.should have(2).records
      @scanner.blocks[0].segments.should have(5).records
      segment_types(@scanner.blocks[0]).should == [:copy, :update, :copy, :update, :copy]
      @scanner.blocks[1].segments.should have(3).records    
      segment_types(@scanner.blocks[1]).should == [:copy, :update, :copy]
    end
        
  end

end

