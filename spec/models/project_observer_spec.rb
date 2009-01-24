require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectObserver do
  
  it 'should observe the Project class' do
    ProjectObserver.should observe(Project)
  end

end
