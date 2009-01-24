require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Attachment do

  def build_attachment(content, name = 'file.rb', type = 'text/plain')    
    @stream = ActionController::UploadedStringIO.new(content)
    @stream.original_path = name
    @stream.content_type = type
    Attachment.new(@stream)
  end

  describe 'initialising' do
    
    describe 'if passed stream is invalid' do
      before do 
        @a1 = Attachment.new(nil)
        @a2 = Attachment.new(456)
      end
    
      it 'should be marked as not ready to save' do
        @a1.should_not be_ready_to_save
        @a2.should_not be_ready_to_save        
      end
      it 'should have no file name' do
        @a1.file_name.should be_blank
        @a2.file_name.should be_blank
      end      
      it 'should have no content-type' do
        @a1.content_type.should be_blank
        @a2.content_type.should be_blank
      end      

      it 'should not be valid' do
        @a1.should have(1).error_on(:content)
        @a1.should have(1).error_on(:content_type)
        @a1.should have(1).error_on(:file_name)
      end
    
    end

    describe 'if passed stream is empty' do
      before do 
        @a1 = build_attachment('')
      end
    
      it 'should be marked as not ready to save' do
        @a1.should_not be_ready_to_save
      end      
      
      it 'should have no file name' do
        @a1.file_name.should be_blank
      end      

      it 'should have no content-type' do
        @a1.content_type.should be_blank
      end      

      it 'should not be valid' do
        @a1.should have(1).error_on(:content)
        @a1.should have(1).error_on(:content_type)
        @a1.should have(1).error_on(:file_name)
      end
    end

    describe 'if passed stream is valid' do
      
      it 'should be ready to save' do
        build_attachment('A').should be_ready_to_save
      end

      it 'should sanitize and store the file name' do
        build_attachment('A', '/root/my_doc.rb').file_name.should == 'my_doc.rb'
        build_attachment('A', 'C:\Documents\my_doc.rb').file_name.should == 'my_doc.rb'
        build_attachment('A', 'C:\\Documents\\my_doc.rb').file_name.should == 'my_doc.rb'
      end
      
      it 'should store the content type' do
        build_attachment('A').content_type.should == 'text/plain'
      end

      it 'should identify textual content types' do
        build_attachment('TEXT', 'file.txt', 'text/plain').should be_textual
        build_attachment('GIF89', 'file.gif', 'image/gif').should_not be_textual
        build_attachment('PDF', 'file.pdf', 'application/pdf').should_not be_textual
      end

      it 'should identify image content types' do
        build_attachment('TEXT', 'file.txt', 'text/plain').should_not be_image
        build_attachment('GIF89', 'file.gif', 'image/gif').should be_image
        build_attachment('PDF', 'file.pdf', 'application/pdf').should_not be_image
      end

      it 'should identify inline content types' do
        build_attachment('TEXT', 'file.txt', 'text/plain').should be_inline
        build_attachment('GIF89', 'file.gif', 'image/gif').should be_inline
        build_attachment('PDF', 'file.pdf', 'application/pdf').should_not be_inline
      end

      it 'should have a size' do
        build_attachment('A').size.should == 1
        build_attachment('ABC').size.should == 3
      end

      it 'should have a content' do
        build_attachment('A').read.should == 'A'
        build_attachment('ABC').read.should == 'ABC'
      end
      
    end

  end

  describe 'saving' do

    before do
      @attachment = build_attachment('ABC')
    end

    it 'should validate presence of content' do
      @attachment.should validate_presence_of(:content)
    end

    it 'should validate presence of content type' do
      @attachment.should validate_presence_of(:content_type)
    end

    it 'should validate presence of file-name' do
      @attachment.should validate_presence_of(:file_name)
    end

    it 'should validate presence of file-name' do
      Attachment.stub!(:max_size).and_return(5)
      @attachment.should have(:no).errors
      Attachment.stub!(:max_size).and_return(2)
      @attachment.should have(1).error_on(:base)
    end

    it 'should verify that storage directory is present' do
      @attachment.should have(:no).errors
      File.should_receive(:directory?).with(Attachment.storage_path).and_return(false)
      @attachment.should have(1).error_on(:base)
    end

    it 'should verify that file can be written' do
      @attachment.should have(:no).errors
      File.should_receive(:writable?).with(Attachment.storage_path).and_return(false)
      @attachment.should have(1).error_on(:base)
    end

  end

  describe 'existing' do
    fixtures :attachments
    load_attachment_fixtures    

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
