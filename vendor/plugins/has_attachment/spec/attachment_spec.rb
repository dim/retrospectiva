require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Attachment do
  include DefautAttachmentSpec
  it 'should have a global maximum file size' do
    Attachment.max_size = 4.megabytes
    Attachment.max_size.should == 4.megabytes
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
        @a1.should_not be_valid
        Array(@a1.errors[:content]).compact.should have(1).item
        Array(@a1.errors[:content_type]).compact.should have(1).item
        Array(@a1.errors[:file_name]).compact.should have(1).item
      end
    
    end

    describe 'if passed stream is empty' do
      before do 
        @a1 = new_attachment('')
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
        @a1.should_not be_valid
        Array(@a1.errors[:content]).compact.should have(1).item
        Array(@a1.errors[:content_type]).compact.should have(1).item
        Array(@a1.errors[:file_name]).compact.should have(1).item
      end
    end
  
    describe 'if passed stream is valid' do
      
      it 'should be ready to save' do
        new_attachment('A').should be_ready_to_save
      end

      it 'should sanitize and store the file name' do
        new_attachment('A', '/root/my_doc.rb').file_name.should == 'my_doc.rb'
        new_attachment('A', 'C:\Documents\my_doc.rb').file_name.should == 'my_doc.rb'
        new_attachment('A', 'C:\\Documents\\my_doc.rb').file_name.should == 'my_doc.rb'
      end
      
      it 'should store the content type' do
        new_attachment('A').content_type.should == 'text/plain'
      end

      it 'should identify html content types' do
        new_attachment('TEXT', 'file.txt', 'text/plain').should_not be_html
        new_attachment('HTML', 'file.html', 'text/html').should be_html
      end

      it 'should identify plain textual content types' do
        new_attachment('TEXT', 'file.txt', 'text/plain').should be_plain
        new_attachment('CSV', 'file.csv', 'text/csv').should be_plain
        new_attachment('HTML', 'file.html', 'text/html').should_not be_plain
        new_attachment('GIF89', 'file.gif', 'image/gif').should_not be_plain
        new_attachment('PDF', 'file.pdf', 'application/pdf').should_not be_plain
      end

      it 'should identify image content types' do
        new_attachment('TEXT', 'file.txt', 'text/plain').should_not be_image
        new_attachment('GIF89', 'file.gif', 'image/gif').should be_image
        new_attachment('PDF', 'file.pdf', 'application/pdf').should_not be_image
      end

      it 'should identify inline content types' do
        new_attachment('TEXT', 'file.txt', 'text/plain').should be_inline
        new_attachment('GIF89', 'file.gif', 'image/gif').should be_inline
        new_attachment('PDF', 'file.pdf', 'application/pdf').should_not be_inline
      end

      it 'should have a size' do
        new_attachment('A').size.should == 1
        new_attachment('ABC').size.should == 3
      end

    end

  end
  
  describe 'saving' do

    before do
      @attachment = new_attachment('ABC')
    end

    it 'should validate presence of content' do
      @attachment.stub!(:content).and_return(nil)
      @attachment.should_not be_valid
      Array(@attachment.errors[:content]).compact.should have(1).item
    end

    it 'should validate presence of content type' do
      @attachment.stub!(:content_type).and_return(nil)
      @attachment.should_not be_valid
      Array(@attachment.errors[:content_type]).compact.should have(1).item
    end

    it 'should validate presence of file-name' do
      @attachment.stub!(:file_name).and_return(nil)
      @attachment.should_not be_valid
      Array(@attachment.errors[:file_name]).compact.should have(1).item
    end

    it 'should validate presence of file-name' do
      Attachment.stub!(:max_size).and_return(5)
      @attachment.should be_valid
      @attachment.should have(:no).errors

      Attachment.stub!(:max_size).and_return(2)
      @attachment.should_not be_valid
      @attachment.should have(1).error
    end  
  end
  
end
