require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RepositoriesHelper do
  
  describe 'commit log formatting' do

    before do
      helper.stub!(:markup).and_return('MARKUP')
      helper.stub!(:simple_markup).and_return('SIMPLE')
    end
    
    it 'should use markup to render log if wikified is enabled' do
      helper.should_receive(:wikify_log?).and_return(true)
      helper.format_log('LOG').should == 'MARKUP'
    end

    it 'should use markup to render log if wikified is enabled' do
      helper.should_receive(:wikify_log?).and_return(false)
      helper.format_log('LOG').should == 'SIMPLE'
    end    

  end
  
end
