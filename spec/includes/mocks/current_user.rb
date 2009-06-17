ActionController::TestCase.class_eval do

  def mock_current_user!(methods = {})
    user = mock_model(User, methods.reverse_merge(:public? => false))
    user.stub!(:time_zone).and_return('London')
    User.stub!(:current).and_return(user)      
    user
  end

end
