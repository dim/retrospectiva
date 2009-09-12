require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AssociationProxies::UserProjects do
  fixtures :users, :groups_users, :groups, :groups_projects, :projects

  describe 'in general' do
    before do
      @proxy = AssociationProxies::UserProjects.instantiate(users(:admin))
    end
    
    it 'should select projects' do
      @proxy.should have(3).records
    end

    it 'should be able to limit to active projects' do
      @proxy.active.should have(2).record
      @proxy.active.should be_instance_of(AssociationProxies::UserProjects)
    end

  end
  
  describe 'when user is an admin' do
    before do
      @proxy = AssociationProxies::UserProjects.instantiate(users(:admin))
    end

    it 'should select all available records' do
      @proxy.should have(3).records
    end
  end

  describe 'when user is not an admin' do
    before do
      @proxy = AssociationProxies::UserProjects.instantiate(users(:agent))
    end

    it 'should select projects the user is assigned to' do
      @proxy.should have(1).record
    end
  end

  describe 'finding a project' do
    before do
      @proxy = AssociationProxies::UserProjects.instantiate(users(:admin))
    end

    describe 'if a string is passed' do
      it 'should find the project if its short-name matches' do
        @proxy.find('retrospectiva').should == projects(:retro)
      end

      it 'should return nil if no short-name matches' do
        @proxy.find('non-existing').should be_nil
      end
    end
      
    describe 'if a attribute-hash is passed' do
      it 'should find the project if attributes match' do
        @proxy.find(:name => 'Retrospectiva', :closed => false).should == projects(:retro)
      end
      it 'should return nil if attributes do not match' do
        @proxy.find(:name => 'Retrospectiva', :closed => true).should be_nil
      end
    end

    describe 'if something else is passed' do
      it 'should return nil' do
        @proxy.find([]).should be_nil
      end
    end
  end
  
end
