share_as :EveryAdminAreaController do
  
  def request_restfully(action)
    method, options = case action
    when 'create'
      [:post, {}]
    when 'update'
      [:put, {:id => '123'}]
    when 'destroy'
      [:delete, {:id => '123'}]
    when 'show','edit'
      [:get, {:id => '123'}]
    else
      [:get, {}]
    end
    options.merge!(nested_controller_options) if respond_to?(:nested_controller_options)
    send(method, action, options)
  end

  it "should be an admin controller" do
    controller.should be_an_kind_of(AdminAreaController)
  end

  it "should grant access to administrators" do
    mock_current_user!(:admin? => true)
    controller.class.rspec_reset
    controller.send(:action_methods).each do |action|      
      lambda { request_restfully(action) }.should_not raise_error(RetroAM::NoAuthorizationError)
    end
  end

  it "should deny access to ordinary users" do
    mock_current_user!(:admin? => false)
    controller.class.rspec_reset    
    controller.send(:action_methods).each do |action|
      lambda { request_restfully(action) }.should raise_error(RetroAM::NoAuthorizationError)
    end
  end

end unless Object.const_defined?(:EveryAdminAreaController)
