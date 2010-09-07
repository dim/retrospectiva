ActionController::TestCase.class_eval do

  def stub_current_project!(methods = {}, &block)
    stub_model(Project, methods).tap do |project|
      project.short_name ||= (project.name.present? ? project.name.parameterize : project.id.to_s)
      yield project if block_given?
      Project.stub!(:current).and_return(project)
    end
  end

end
