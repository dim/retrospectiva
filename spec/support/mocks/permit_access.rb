ActionController::TestCase.class_eval do
  def permit_access!
    @controller.class.stub!(:authorize?).and_return(true)
    @retro_cm_configuration = mock_model(RetroCM::Configuration, :section_hash => {}, :updated_at => Time.now, :apply => true)
    RetroCM::Configuration.stub!(:find_or_create).and_return(@retro_cm_configuration)
  end

  def permit_access_with_current_project!(methods = {})
    permit_access!
    @controller.stub!(:find_project).and_return(true)
    stub_current_project! methods
  end
end
