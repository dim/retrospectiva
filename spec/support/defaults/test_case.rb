ActiveSupport::TestCase.class_eval do
  
  before(:all) do
    RetroCM[:general][:basic][:site_url] = 'http://test.host'
  end

  before(:each) do
    I18n.stub!(:locale).and_return(:'en-US')
    Project.stub!(:central).and_return(false)
  end

  after(:all) do
    User.current = nil
    Project.current = nil
  end

end
