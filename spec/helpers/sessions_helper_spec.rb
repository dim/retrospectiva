require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionsHelper do
  
  describe 'configuration checks' do
    
    it 'should return the value for secure authentication setting' do
      RetroCM[:general][:user_management].should_receive(:[]).with(:secure_auth).and_return true
      helper.secure_auth?.should be(true)
    end

    it 'should return the value for account management setting' do
      RetroCM[:general][:user_management].should_receive(:[]).with(:account_management).and_return true
      helper.account_management?.should be(true)
    end
    
    it 'should return the value for self registration setting' do
      RetroCM[:general][:user_management].should_receive(:[]).with(:self_registration).and_return true
      helper.self_registration?.should be(true)
    end    
  end
  
  describe 'secure authication form' do

    before do 
      helper.stub!(:secure_auth?).and_return(true)      
    end
    
    it 'should include two additional tag for secure authentication' do
      helper.secure_auth_tags.should have_tag('input[type=hidden]', 2)
    end
    
    it 'should include on-submit javascript-callback' do
      helper.should_receive(:js_code_for_secure_auth).and_return('JS_CODE')
      helper.send(:html_options_for_login_form).should == { :onsubmit => 'JS_CODE', :id => 'login_form' }
    end
    
  end
  

end
