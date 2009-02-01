require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LoginToken do
  fixtures :secure_tokens, :users
  
  before(:each) do
    @token = LoginToken.new
  end

  it "should validate presence of user ID" do
    @token.should validate_presence_of(:user_id)
  end

  it "should validate belong to a user" do
    @token.should belong_to(:user)
  end

end
