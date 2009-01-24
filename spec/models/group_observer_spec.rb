require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupObserver do
  
  it 'should observe the Group class' do
    GroupObserver.should observe(Group)
  end

end
