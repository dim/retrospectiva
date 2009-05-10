require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TicketPropertyValuesController do
  def nested_controller_options
    { :project_id => 'retro', :ticket_property_id => '1' }
  end  
  it_should_behave_like EveryAdminAreaController

  before do
    permit_access!

    @statuses = [mock_model(Status)]
    @priorities = [mock_model(Priority)]
    @property_values = [mock_model(TicketProperty)]

    @property_type = mock_model(TicketPropertyType, :global? => false)
    @property_type.stub!(:ticket_properties).and_return(@property_values)

    @property_types = [@property_type]
    @property_types.stub!(:find).and_return(@property_type)
    @project = mock_model(Project)
    @project.stub!(:ticket_property_types).and_return @property_types

    Project.stub!(:find_by_short_name!).and_return(@project)
  end

  def self.it_should_find_the_related_project(method = :do_get)
    it "should find the related project" do
      Project.should_receive(:find_by_short_name!).and_return(@project)
      send(method)
      assigns[:project].should == @project
    end
  end
  
  def self.it_should_find_the_property_type(method = :do_get)
    it "should find the property type" do
      @property_types.should_receive(:find).with('1', :include=>[:ticket_properties]).and_return(@property_type)
      send(method)
      assigns[:property_type].should == @property_type
    end  
  end  

  describe "handling GET /admin/project_name/ticket_properties/1/values" do

    def do_get
      get :index, :project_id => 'retro', :ticket_property_id => '1'
    end      

    it_should_successfully_render_template('index')
    it_should_find_the_related_project
    it_should_find_the_property_type

    it "should find the property values" do
      @property_type.should_receive(:ticket_properties).and_return(@property_values)
      do_get
    end

    it "should assign the property values for the view" do
      do_get
      assigns[:property_values].should == @property_values
    end
  
  end



  describe "handling GET /admin/project_name/ticket_properties/Status/values" do
    before  do
      Status.stub!(:find).and_return(@statuses)      
    end

    def do_get
      get :index, :project_id => 'retro', :ticket_property_id => 'Status'
    end      

    it_should_successfully_render_template('index')
    it_should_find_the_related_project

    it "should identify Status as the property type" do
      do_get
      assigns[:property_type].should == Status
    end

    it "should find the statuses" do
      Status.should_receive(:find).with(:all, :order => 'rank').and_return(@statuses)
      do_get
    end

    it "should assign the statuses for the view" do
      do_get
      assigns[:property_values].should == @statuses
    end
  
  end



  describe "handling GET /admin/project_name/ticket_properties/Priority/values" do
    before  do
      Priority.stub!(:find).and_return(@priorities)      
    end

    def do_get
      get :index, :project_id => 'retro', :ticket_property_id => 'Priority'
    end      

    it_should_successfully_render_template('index')
    it_should_find_the_related_project

    it "should identify Priority as the property type" do
      do_get
      assigns[:property_type].should == Priority
    end

    it "should find the priorities" do
      Priority.should_receive(:find).with(:all, :order => 'rank').and_return(@priorities)
      do_get
    end

    it "should assign the priorities for the view" do
      do_get
      assigns[:property_values].should == @priorities
    end
  
  end



  describe "handling GET /admin/project_name/ticket_properties/1/values/new" do
    
    before do
      @property_value = mock_model(TicketProperty)
      @property_values.stub!(:new).and_return(@property_value)
    end

    def do_get
      get :new, :project_id => 'retro', :ticket_property_id => '1', :ticket_property => {}
    end      

    it_should_successfully_render_template('new')
    it_should_find_the_related_project
    it_should_find_the_property_type

    it "should create a new property value" do
      @property_values.should_receive(:new).with({}).and_return(@property_value)
      do_get
    end

    it "should not save the value" do
      @property_value.should_not_receive(:save)
      do_get
    end

    it "should assign the property value for the view" do
      do_get
      assigns[:ticket_property].should == @property_value
    end
  
  end



  describe "handling GET /admin/project_name/ticket_properties/Status/values/new" do
    
    before do
      @property_value = mock_model(Status)
      Status.stub!(:new).and_return(@property_value)
    end

    def do_get
      get :new, :project_id => 'retro', :ticket_property_id => 'Status', :status => {}
    end      

    it_should_successfully_render_template('new')
    it_should_find_the_related_project

    it "should create a new status" do
      Status.should_receive(:new).with({}).and_return(@property_value)
      do_get
    end

    it "should assign the status for the view" do
      do_get
      assigns[:ticket_property].should == @property_value
    end
  
  end



  describe "handling GET /admin/project_name/ticket_properties/Priority/values/new" do
    
    before do
      @property_value = mock_model(Priority)
      Priority.stub!(:new).and_return(@property_value)
    end

    def do_get
      get :new, :project_id => 'retro', :ticket_property_id => 'Priority', :priority => {}
    end      

    it_should_successfully_render_template('new')
    it_should_find_the_related_project

    it "should create a new priority" do
      Priority.should_receive(:new).with({}).and_return(@property_value)
      do_get
    end

    it "should assign the priority for the view" do
      do_get
      assigns[:ticket_property].should == @property_value
    end
  
  end




  describe "handling POST /admin/project_name/ticket_properties/1/values" do
    
    before do
      @property_value = mock_model(TicketProperty)
      @property_values.stub!(:new).and_return(@property_value)
    end

    def do_post(success = true)
      @property_value.stub!(:save).and_return(success)
      post :create, :project_id => 'retro', :ticket_property_id => '1', :ticket_property => {}
    end      

    it_should_find_the_related_project(:do_post)
    it_should_find_the_property_type(:do_post)

    it "should create a new property value" do
      @property_values.should_receive(:new).with({}).and_return(@property_value)
      do_post
    end

    describe 'with valid attributes' do

      it "should save the value" do
        @property_value.should_receive(:save).and_return(true)
        do_post
      end

      it "should redirect to values overview" do
        do_post
        response.should be_redirect
        response.should redirect_to(admin_project_ticket_property_values_path(@project, @property_type))
      end

    end

    describe 'with invalid attributes' do

      def do_post
        super(false)
      end      

      it "should not save the value" do
        @property_value.should_receive(:save).and_return(false)
        do_post
      end

      it_should_successfully_render_template('new', :do_post)
    end
  
  end



  describe "handling POST /admin/project_name/ticket_properties/Status/values" do

    it "should create a new status" do
      @status = mock_model(Status)
      Status.should_receive(:new).with({}).and_return(@status)
      @status.should_receive(:save).and_return(true)
      post :create, :project_id => 'retro', :ticket_property_id => 'Status', :status => {}
    end
  
  end

  describe "handling POST /admin/project_name/ticket_properties/Priority/values" do

    it "should create a new priority" do
      @priority = mock_model(Priority)
      Priority.should_receive(:new).with({}).and_return(@priority)
      @priority.should_receive(:save).and_return(true)
      post :create, :project_id => 'retro', :ticket_property_id => 'Priority', :priority => {}
    end
  
  end



  describe "handling GET /admin/project_name/ticket_properties/1/values/1/edit" do
    
    before do
      @property_value = mock_model(TicketProperty, :to_param => '1')
      @property_values.stub!(:find).and_return(@property_value)
    end

    def do_get
      get :edit, :project_id => 'retro', :ticket_property_id => '1', :id => '1'
    end      

    it_should_successfully_render_template('edit')
    it_should_find_the_related_project
    it_should_find_the_property_type

    it "should find the property value" do
      @property_values.should_receive(:find).with('1').and_return(@property_value)
      do_get
    end

    it "should not update the value" do
      @property_value.should_not_receive(:save)
      do_get
    end

    it "should assign the property value for the view" do
      do_get
      assigns[:ticket_property].should == @property_value
    end
  
  end


  describe "handling GET /admin/project_name/ticket_properties/Status/values/1/edit" do
    
    before do
      @property_value = mock_model(Status, :to_param => '1')
      Status.stub!(:find).and_return(@property_value)
    end

    def do_get
      get :edit, :project_id => 'retro', :ticket_property_id => 'Status', :id => '1'
    end      

    it_should_successfully_render_template('edit')
    it_should_find_the_related_project

    it "should find the status" do
      Status.should_receive(:find).with('1').and_return(@property_value)
      do_get
    end

    it "should assign the status for the view" do
      do_get
      assigns[:ticket_property].should == @property_value
    end
  
  end


  describe "handling GET /admin/project_name/ticket_properties/Priority/values/new" do
    
    before do
      @property_value = mock_model(Priority, :to_param => '1')
      Priority.stub!(:find).and_return(@property_value)
    end

    def do_get
      get :edit, :project_id => 'retro', :ticket_property_id => 'Priority', :id => '1'
    end      

    it_should_successfully_render_template('edit')
    it_should_find_the_related_project

    it "should find the priority" do
      Priority.should_receive(:find).with('1').and_return(@property_value)
      do_get
    end

    it "should assign the status for the view" do
      do_get
      assigns[:ticket_property].should == @property_value
    end
  
  end




  describe "handling PUT /admin/project_name/ticket_properties/1/values/1" do
    
    before do
      @property_value = mock_model(TicketProperty, :to_param => '1')
      @property_values.stub!(:find).and_return(@property_value)
    end

    def do_put(success = true)
      @property_value.stub!(:update_attributes).and_return(success)
      put :update, :project_id => 'retro', :ticket_property_id => '1', :id => '1', :ticket_property => {}
    end      

    it_should_find_the_related_project(:do_put)
    it_should_find_the_property_type(:do_put)

    it "should find the property value" do
      @property_values.should_receive(:find).with('1').and_return(@property_value)
      do_put
    end

    describe 'with valid attributes' do

      it "should update the property value" do
        @property_value.should_receive(:update_attributes).with({}).and_return(true)
        do_put
      end

      it "should redirect to values overview" do
        do_put
        response.should be_redirect
        response.should redirect_to(admin_project_ticket_property_values_path(@project, @property_type))
      end

    end

    describe 'with invalid attributes' do

      def do_put
        super(false)
      end      

      it "should not update the value" do
        @property_value.should_receive(:update_attributes).with({}).and_return(false)
        do_put
      end

      it_should_successfully_render_template('edit', :do_put)
    end
  
  end


  describe "handling PUT /admin/project_name/ticket_properties/Status/values" do

    it "should update the status" do
      @status = mock_model(Status, :to_param => '1')
      Status.should_receive(:find).with('1').and_return(@status)
      @status.should_receive(:update_attributes).with({}).and_return(true)
      put :update, :project_id => 'retro', :ticket_property_id => 'Status', :id => '1', :status => {}
    end
  
  end

  describe "handling POST /admin/project_name/ticket_properties/Priority/values" do

    it "should update the priority" do
      @priority = mock_model(Priority, :to_param => '1')
      Priority.should_receive(:find).with('1').and_return(@priority)
      @priority.should_receive(:update_attributes).with({}).and_return(true)
      put :update, :project_id => 'retro', :ticket_property_id => 'Priority', :id => '1', :priority => {}
    end
  
  end



  describe "handling DELETE /admin/project_name/ticket_properties/1/values/1" do
    
    before do
      @property_value = mock_model(TicketProperty, :to_param => '1', :destroy => true)
      @property_values.stub!(:find).and_return(@property_value)
    end

    def do_delete
      delete :destroy, :project_id => 'retro', :ticket_property_id => '1', :id => '1'
    end      

    it_should_find_the_related_project(:do_delete)
    it_should_find_the_property_type(:do_delete)

    it "should delete the property value" do
      @property_value.should_receive(:destroy).and_return(@property_value)
      do_delete
    end

    it "should redirect to property values index" do
      do_delete
      response.should be_redirect
      response.should redirect_to(admin_project_ticket_property_values_path(@project, @property_type))
    end

  end


  describe "handling DELETE /admin/project_name/ticket_properties/Status/values/1" do
    
    it "should delete the status" do
      @property_value = mock_model(Status, :to_param => '1')
      Status.should_receive(:find).with('1').and_return(@property_value)
      @property_value.should_receive(:destroy).and_return(@property_value)
      delete :destroy, :project_id => 'retro', :ticket_property_id => 'Status', :id => '1'
    end

  end


  describe "handling DELETE /admin/project_name/ticket_properties/Priority/values/1" do
    
    it "should delete the status" do
      @property_value = mock_model(Priority, :to_param => '1')
      Priority.should_receive(:find).with('1').and_return(@property_value)
      @property_value.should_receive(:destroy).and_return(@property_value)
      delete :destroy, :project_id => 'retro', :ticket_property_id => 'Priority', :id => '1'
    end

  end



  describe "handling PUT /admin/project_name/ticket_properties/1/values/sort" do
    
    before do
      TicketProperty.stub!(:update_all).and_return(true)
    end
    
    def do_put
      xhr :put, :sort, :project_id => 'retro', :ticket_property_id => '1', :property_values => ['3', '1', '2']        
    end

    it_should_find_the_related_project(:do_put)
    it_should_find_the_property_type(:do_put)

    it "should update the records" do
      TicketProperty.should_receive(:update_all).
        with(['rank = ?', 0], ['id = ?', 3]).and_return(true)
      TicketProperty.should_receive(:update_all).
        with(['rank = ?', 1], ['id = ?', 1]).and_return(true)
      TicketProperty.should_receive(:update_all).
        with(['rank = ?', 2], ['id = ?', 2]).and_return(true)
      do_put
    end

    it "should render nothing" do
      do_put
      response.should be_success
      response.body.should be_blank
    end

  end


  describe "handling PUT /admin/project_name/ticket_properties/Status/values/sort" do
    
    it "should update the records" do
      Status.should_receive(:update_all).
        with(['rank = ?', 0], ['id = ?', 3]).and_return(true)
      Status.should_receive(:update_all).
        with(['rank = ?', 1], ['id = ?', 2]).and_return(true)
      xhr :put, :sort, :project_id => 'retro', :ticket_property_id => 'Status', :property_values => ['3', '2']        
    end

  end


  describe "handling PUT /admin/project_name/ticket_properties/Priority/values/sort" do
    
    it "should update the records" do
      Priority.should_receive(:update_all).
        with(['rank = ?', 0], ['id = ?', 3]).and_return(true)
      Priority.should_receive(:update_all).
        with(['rank = ?', 1], ['id = ?', 2]).and_return(true)
      xhr :put, :sort, :project_id => 'retro', :ticket_property_id => 'Priority', :property_values => ['3', '2']
    end

  end



end
