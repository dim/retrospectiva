require 'spec_helper'

describe Attachment do

  it 'should use the RetroCM setting to determine the maximum file size' do
    RetroCM[:general][:attachments].should_receive(:[]).with(:max_size).and_return(4096)
    Attachment.max_size.should == 4096.kilobytes
  end

end
