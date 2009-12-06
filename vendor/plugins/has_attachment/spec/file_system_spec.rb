require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Attachment do
  include DefautAttachmentSpec

  describe 'in file-system mode' do    

    before do
      @attachment = new_attachment('ABC')
    end

    it 'should verify that storage directory is present' do
      @attachment.should be_valid
      @attachment.should have(:no).errors
      
      File.should_receive(:directory?).with(Attachment.storage.path).and_return(false)
      @attachment.should_not be_valid
      @attachment.should have(1).error
    end

    it 'should verify that file can be written' do
      @attachment.should be_valid
      @attachment.should have(:no).errors

      File.should_receive(:writable?).with(Attachment.storage.path).and_return(false)
      @attachment.should_not be_valid
      @attachment.should have(1).error
    end

  end
  
  describe 'creating' do
    before do
      @attachment = new_attachment('ABC')
    end
    
    it 'should write a file if successful' do      
      @attachment.save.should be(true)
      File.exist?("#{TEMP_PATH}/#{@attachment.id}").should be(true)
    end
    
  end

  describe 'deleting' do
    before do
      @attachment = attachments(:text)
      @path = "#{TEMP_PATH}/#{@attachment.id}"
    end
    
    it 'should write a file if successful' do      
      File.exist?(@path).should be(true)
      attachments(:text).destroy 
      File.exist?(@path).should be(false)
    end
    
  end
  
  describe 'existing' do

    it 'should not be a redirect attachment' do
      attachments(:text).should_not be_redirect
    end

    it 'should have send arguments' do
      attachments(:text).send_arguments.should == ["#{TEMP_PATH}/1", {:type=>"text/plain", :filename=>"file.rb", :disposition=>"inline"}]
      attachments(:image).send_arguments.should == ["#{TEMP_PATH}/2", {:type=>"image/gif", :filename=>"file.gif", :disposition=>"inline"}]
      attachments(:binary).send_arguments.should == ["#{TEMP_PATH}/3", {:type=>"application/octet-stream", :filename=>"file.std", :disposition=>"attachment"}]
    end
      
    describe 'if file is present' do
     
      it 'should have a size' do
        attachments(:text).size.should == 49
        attachments(:image).size.should == 83
        attachments(:binary).size.should == 3
      end

      it 'should be readable' do
        attachments(:text).should be_readable
      end
            
    end

    describe 'if file is missing' do

      it 'should have a size of zero' do
        attachments(:missing).size.should be_zero
      end
      
      it 'should not be readble' do
        attachments(:missing).should_not be_readable
      end
    
    end
    
  end
end
