Spec::Rails::Example.class_eval do
  module MockCurrentProjectExtension
    def mock_current_project!(methods = {}, &block)
      project = mock_model(Project, methods)
      Project.stub!(:current).and_return(project)
      yield project if block_given?
      project
    end
  end
end

Spec::Rails::Example::FunctionalExampleGroup.class_eval do
  include MockCurrentProjectExtension
end
