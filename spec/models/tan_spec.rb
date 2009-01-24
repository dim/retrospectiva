require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tan do
  fixtures 'tans'
  
  before(:each) do
    @tan = Tan.new
  end

  it "should validate presence of value" do
    @tan.stub!(:value).and_return(nil)
    @tan.should validate_presence_of(:value)
  end

  it "should validate presence of expiration-time" do
    @tan.stub!(:expires_at).and_return(nil)
    @tan.should validate_presence_of(:expires_at)
  end
  
  it "should generate records" do
    Time.stub!(:now).and_return(Time.local(2008, 1, 1))
    value = Tan.generate
    record = Tan.find_by_value(value).expires_at.should == Time.now.utc + Tan.default_expire_after
  end

  it "should generate records with custom expiration time" do
    Time.stub!(:now).and_return(Time.local(2008, 1, 1))
    value = Tan.generate(1.minute)
    record = Tan.find_by_value(value).expires_at.should == Time.now.utc + 1.minute
  end

  describe 'spending tans' do
    it "should return true if a record exists" do
      Time.stub!(:now).and_return(tans(:one).expires_at - 1.minute)
      Tan.spend(tans(:one).value).should == tans(:one).value
    end

    it "should return false if a record has expired" do
      Time.stub!(:now).and_return(tans(:one).expires_at + 1.minute)
      Tan.spend(tans(:one).value).should be_nil
    end

    it "should return false if record cannot be found" do
      Tan.stub!(:find_by_value).and_return(nil)
      Tan.spend(tans(:one).value).should be_nil
    end  
  end
  
end
