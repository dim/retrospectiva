ActionController::TestCase.class_eval do

  def stub_current_user!(methods = {})
    user = stub_model(User, methods.reverse_merge(:public? => false))
    user.stub!(:time_zone).and_return('London')
    User.stub!(:current).and_return(user)      
    user
  end

end
