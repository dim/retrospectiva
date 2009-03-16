ActionController::TestCase.class_eval do

  def mock_current_project!(methods = {}, &block)
    project = mock_model(Project, methods)
    Project.stub!(:current).and_return(project)
    yield project if block_given?
    project
  end

end
