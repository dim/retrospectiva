require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Attachment do
  include DefautAttachmentSpec

  describe 'in S3 mode' do
    before do
      Attachment.storage = { :type => :s3, :access_key_id => '123', :secret_access_key => 'xyz', :bucket => 'mystuff' }
    end

    describe 'creating' do
      
      it 'should send a correct service request' do        
        AWS::S3::S3Object.should_receive(:store).with('1000', 'ABC', 'mystuff', :content_type => 'text/plain')
        new_attachment('ABC').should be_valid 
        new_attachment('ABC').save.should be(true)        
      end

      it 'should prevent save if service credentials are not valid' do        
        new_attachment('ABC').should be_valid
        lambda { new_attachment('ABC').save }.should raise_error        
      end
      
    end

    describe 'deleting' do
      
      it 'should send a correct service request' do        
        AWS::S3::S3Object.should_receive(:delete).with('1', 'mystuff')
        attachments(:text).destroy 
      end

      it 'should ignore errors' do        
        lambda { attachments(:text).destroy }.should_not raise_error 
      end
      
    end

    describe 'existing' do

      it 'should not be a redirect attachment' do
        attachments(:text).should be_redirect
      end

      it 'should generate a temporary url' do
        attachments(:text).redirect_url.should match(%r{^http://s3.amazonaws.com/mystuff/1\?})
      end

    end
  end
end
