require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QueuedMail do
  
  describe 'an instance' do

    before(:each) do
      @mail = mock_model(TMail::Mail)
      QueuedMail.stub!(:deliver).and_return(true)
      @queued_mail = QueuedMail.new(:object => @mail, :mailer_class_name => 'QueuedMail')
      @queued_mail.stub!(:update_attribute).and_return(true)
    end
  
    it "should validate presence of an email object" do
      @queued_mail.should validate_presence_of(:object)
    end
  
    it "should validate presence of a mailer class" do
      @queued_mail.should validate_presence_of(:mailer_class_name)
    end
  
    describe 'finding the mailer-class' do

      it 'should return the mailer-class if valid' do
        @queued_mail.mailer_class.should == QueuedMail
      end

      it 'should return nil if not valid' do
        @queued_mail.mailer_class_name = 'QueuedMail12345'
        @queued_mail.mailer_class.should be_nil
      end

    end

    describe 'delivering the mail' do
      before do
        @time = Time.now
        Time.stub!(:now).and_return(@time)
      end
    
      it 'should not deliver the mail if mailer-class cannot be found' do
        @queued_mail.mailer_class_name = 'QueuedMail12345'
        @queued_mail.deliver!.should be(false)        
      end

      it 'should deliver the mail if mailer-class can be found' do
        QueuedMail.should_receive(:deliver).with(@mail).and_return(true)
        @queued_mail.deliver!.should be(true)        
      end

      it 'should destroy the queued record after delivery' do
        @queued_mail.should_receive(:update_attribute).with(:delivered_at, @time.utc).and_return(true)
        @queued_mail.deliver!.should be(true)
      end

    end

  end

  describe 'the class' do 
    fixtures :queued_mails
    
    it 'should find pending records' do
      QueuedMail.pending.should have(2).records
    end

  end

end
