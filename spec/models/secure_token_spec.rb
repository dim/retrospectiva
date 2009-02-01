require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SecureToken do
  fixtures 'secure_tokens'
  
  before(:each) do
    @token = SecureToken.new
  end

  it "should validate presence of value" do
    @token.stub!(:value).and_return(nil)
    @token.should validate_presence_of(:value)
  end

  it "should validate presence of expiration-time" do
    @token.stub!(:expires_at).and_return(nil)
    @token.should validate_presence_of(:expires_at)
  end
  
  it "should generate records" do
    Time.stub!(:now).and_return(Time.local(2008, 1, 1))
    value = SecureToken.generate
    record = SecureToken.spend(value).expires_at.should == Time.now.utc + SecureToken.default_expire_after
  end

  it "should generate records with custom expiration time" do
    Time.stub!(:now).and_return(Time.local(2008, 1, 1))
    value = SecureToken.generate(1.minute)
    record = SecureToken.spend(value).expires_at.should == Time.now.utc + 1.minute
  end

  describe 'spending secure_tokens' do
    
    it "should return true if a record exists" do
      Time.stub!(:now).and_return(secure_tokens(:one).expires_at - 1.minute)
      SecureToken.spend(secure_tokens(:one).to_s).should == secure_tokens(:one)
    end

    it "should return false if a record has expired" do
      Time.stub!(:now).and_return(secure_tokens(:one).expires_at + 1.minute)
      SecureToken.spend(secure_tokens(:one).to_s).should be_nil
    end

    it "should return false if record cannot be found" do
      SecureToken.stub!(:find_by_value).and_return(nil)
      SecureToken.spend(secure_tokens(:one).to_s).should be_nil
    end  
  end

  describe 'spending tokens' do
    
    it "should return true if a record exists" do
      Time.stub!(:now).and_return(secure_tokens(:one).expires_at - 1.minute)
      SecureToken.spend(secure_tokens(:one).to_s).should == secure_tokens(:one)
    end

    it "should return false if a record has expired" do
      Time.stub!(:now).and_return(secure_tokens(:one).expires_at + 1.minute)
      SecureToken.spend(secure_tokens(:one).to_s).should be_nil
    end

    it "should return false if record cannot be found" do
      SecureToken.stub!(:find_by_value).and_return(nil)
      SecureToken.spend(secure_tokens(:one).to_s).should be_nil
    end  
  end

  describe 'token characteristics' do
    
    it "should include ID and value into token string" do
      secure_tokens(:one).to_s.should == "ST-#{secure_tokens(:one).id}-#{secure_tokens(:one).value}" 
    end

  end
  
end
