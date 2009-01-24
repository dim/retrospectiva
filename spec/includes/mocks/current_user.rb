Spec::Rails::Example.class_eval do
  module MockCurrentUserExtension
    def mock_current_user!(methods = {})
      user = mock_model(User, methods)
      user.stub!(:time_zone).and_return('London')
      User.stub!(:current).and_return(user)      
      user
    end
  end
end

Spec::Rails::Example::FunctionalExampleGroup.class_eval do
  include MockCurrentUserExtension
end
