require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  
  describe 'gravatar generation' do
    
    it 'should work correctly and accept options' do
      helper.send(:gravatar, 'me@home.com', :id => 'g01').
        should == "<img alt=\"\" class=\"frame\" id=\"g01\" src=\"http://www.gravatar.com/avatar/c3ed6851b70d51c384f99120711d6f6e.png?s=40\" />"
    end
    
    it 'should accept empty email arguments' do
      helper.send(:gravatar, nil, :size => 10, :alt => 'user-image').
        should == "<img alt=\"user-image\" class=\"frame\" src=\"http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e.png?s=10\" />" 
    end

    it 'should be case insensitive' do
      helper.send(:gravatar, 'me@home.com').should == helper.send(:gravatar, 'ME@home.com')
    end
  
  end

  
end
