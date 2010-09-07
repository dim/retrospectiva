module Spec::TypicalMilestonesControllerSetup
  
  def self.included(base)
    base.before do
      @milestone  = stub_model(Milestone, :name => '1.0', :updated_at => 2.days.ago)
      @milestones = [@milestone]
      @milestones.stub!(:in_default_order).and_return(@milestones)
      @milestones.stub!(:active_on).and_return(@milestones)
      @milestones.stub!(:count)    
      @milestones.stub!(:maximum)    

      @project = stub_model(Project, :name => 'Retro', :short_name => 'retro', :milestones => @milestones)
      @projects = [@project]    
      @projects.stub!(:active).and_return(@projects)
      @projects.stub!(:find).and_return(@project)

      @user = stub_current_user! :projects => @projects,
        :name => 'Public', :public? => true, :admin? => false, :permitted? => true
      
      Project.stub!(:find_by_short_name!).and_return(@project) 
      controller.class.stub!(:module_enabled?).and_return(true)
      controller.class.stub!(:module_accessible?).and_return(true)
    end
  end
  
end