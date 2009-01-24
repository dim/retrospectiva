require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserObserver do
  
  it 'should observe the User class' do
    UserObserver.should observe(User)
  end

end
