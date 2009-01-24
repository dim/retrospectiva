Spec::Rails::Example::RailsExampleGroup.class_eval do
  cattr_accessor :attachments_path
  self.attachments_path = File.join(RAILS_ROOT, 'spec', 'fixtures', 'attachments')

  before(:all) do
    RetroCM[:general][:basic][:site_url] = 'http://test.host'
    Attachment.storage_path = attachments_path    
  end

  before(:each) do
    I18n.stub!(:locale).and_return(:'en-US')
    Project.stub!(:central).and_return(false)
  end

  after(:all) do
    User.current = nil
    Project.current = nil
  end

  class << self
    
    def load_attachment_fixtures
      before do
        File.open(attachments_path + '/1', 'w') {|f| f << "#!/usr/bin/env ruby\nputs 'This is a ruby script!'" }
        File.open(attachments_path + '/2', 'w') {|f| f << "GIF89a^A^@^A^@�^@^@���^@^@^@!�^D^A^@^@^@^@,^@^@^@^@^A^@^A^@^@^B^BD^A^@;if" }
        File.open(attachments_path + '/3', 'w') {|f| f << "..." }
      end
      
      after do 
        Dir[attachments_path + '/*'].each do |file|
          File.unlink(file)
        end      
      end    
    end
    
  end  
end
