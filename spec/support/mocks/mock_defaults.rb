Spec::Rails::Example::FunctionalExampleGroup.class_eval do
  
  before do
    User.stub!(:public_user).and_return(mock_model(User, :id => 0, :name => 'Public', :public? => true, :time_zone => 'London'))
    Group.stub!(:default_group).and_return(mock_model(Group, :id => 0, :name => 'Default', :default? => true))
  end

end
