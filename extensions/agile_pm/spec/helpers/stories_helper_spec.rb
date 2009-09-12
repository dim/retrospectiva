require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoriesHelper do
  
  describe 'story actions' do
    before do
      @story = stub_model(Story)
      helper.stub!(:permitted?).and_return(true)
    end
    
    
    describe 'if user is not permitted to update stories' do

      it 'should return an empty array' do
        helper.should_receive(:permitted?).with(:stories, :update).and_return(false)
        helper.story_actions(@story).should == []
      end
      
    end
  
  end
end

