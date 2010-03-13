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
  
  describe 'hours comparison' do
    before do
      @story = stub_model(Story, :estimated_hours => 16, :revised_hours => 12, :completed? => false)
      helper.stub!(:permitted?).and_return(true)
    end

    describe 'if user is not permitted to update stories' do
      it 'should return a link to hour revision + original hours setting' do
        helper.should_receive(:permitted?).with(:stories, :update).and_return(true)
        helper.should_receive(:in_place_editor_for_hours).with(@story).and_return('[IPE_JS]')
        helper.hours_comparison(@story).should == %(<a href="#" id="story_#{@story.id}_hours" onclick="; return false;">12h</a>[IPE_JS] (16h))
      end
    end
    
    describe 'if user is not permitted to update stories' do
      it 'should return just the hour comparison' do
        helper.should_receive(:permitted?).with(:stories, :update).and_return(false)
        helper.hours_comparison(@story).should == "12h (16h)"
      end      
    end    

    describe 'if story is already completed' do
      it 'should return just the hour comparison' do
        @story.should_receive(:completed?).and_return(true)
        helper.hours_comparison(@story).should == "12h (16h)"
      end      
    end    
  end
  
end

