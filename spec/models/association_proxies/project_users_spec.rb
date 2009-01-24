require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AssociationProxies::ProjectUsers do
  fixtures :projects, :users, :groups, :groups_users, :groups_projects

  it "should find all users that have access to a project" do
    projects(:retro).users.find(:all).should have(3).records
  end

  it "should automatically order users by name" do
    projects(:retro).users.find(:all).should == users(:admin, :agent, :double_agent)
  end

  it "should always exclude Public" do
    projects(:retro).users.find(:all).should_not include(users(:Public))
    projects(:sub).users.find(:all).should_not include(users(:Public))
  end

  it "should always include admins" do
    projects(:retro).users.find(:all).should include(users(:admin))
    projects(:sub).users.find(:all).should include(users(:admin))
  end

  it "should find users with certain permissions" do
    projects(:retro).users.with_permission(:tickets, :view).should == users(:admin, :agent, :double_agent)
    projects(:sub).users.with_permission(:tickets, :view).should == users(:admin, :double_agent)
    projects(:sub).users.with_permission(:tickets, :update).should == [users(:admin)]
  end
  
  it "should be able to find users by custom conditions" do
    projects(:retro).users.find(:first, :conditions => ['username = ?', 'agent']).should == users(:agent)
    projects(:retro).users.find(:all, :conditions => ['LOWER(users.name) LIKE ?', 'a%']).should == users(:admin, :agent)
  end

end
