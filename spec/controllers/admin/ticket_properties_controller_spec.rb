require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TicketPropertiesController do
  def nested_controller_options
    { :project_id => 'retro' }
  end  
  it_should_behave_like EveryAdminAreaController

  before do
    permit_access!
    @project = mock_model(Project)
    Project.stub!(:find_by_short_name!).and_return(@project)
    @ticket_properties = [mock_model(TicketPropertyType)]
    @project.stub!(:ticket_property_types).and_return(@ticket_properties)
  end

  describe "handling GET /admin/project_name/ticket_properties" do

    def do_get
      get :index, :project_id => 'retro'
    end      

    it_should_successfully_render_template('index')

    it "should find the related project" do
      Project.should_receive(:find_by_short_name!).and_return(@project)
      do_get
      assigns[:project].should == @project
    end

    it "should find the ticket properties" do
      @project.should_receive(:ticket_property_types).and_return(@ticket_properties)
      do_get
    end

    it "should assign the ticket properties for the view" do
      do_get
      assigns[:ticket_properties].should == @ticket_properties
    end
  
  end


  describe "handling GET /admin/project_name/ticket_properties/new" do
    
    before do
      @ticket_property_type = mock_model(TicketPropertyType)
      @ticket_properties.stub!(:new).and_return(@ticket_property_type)
    end

    def do_get
      get :new, :project_id => 'retro'
    end      

    it_should_successfully_render_template('new')

    it "should find the related project" do
      Project.should_receive(:find_by_short_name!).and_return(@project)
      do_get
      assigns[:project].should == @project
    end

    it "should create a new ticket property" do
      @ticket_properties.should_receive(:new).with(nil).and_return(@ticket_property_type)
      do_get
    end

    it "should not save the ticket property" do
      @ticket_property_type.should_not_receive(:save)
      do_get
    end

    it "should assign the ticket property for the view" do
      do_get
      assigns[:ticket_property_type].should == @ticket_property_type
    end

  end


  describe "handling POST /admin/project_name/ticket_properties" do
    
    before do
      @ticket_property_type = mock_model(TicketPropertyType)
      @ticket_properties.stub!(:new).and_return(@ticket_property_type)
    end

    def do_post(success = true)
      @ticket_property_type.stub!(:save).and_return(success)
      post :create, :project_id => 'retro', :ticket_property_type => {}
    end      

    it "should find the related project" do
      Project.should_receive(:find_by_short_name!).and_return(@project)
      do_post
      assigns[:project].should == @project
    end

    it "should create a new ticket property" do
      @ticket_properties.should_receive(:new).with({}).and_return(@ticket_property_type)
      do_post
    end

    describe 'with valid attributes' do

      it "should save the ticket property" do
        @ticket_property_type.should_receive(:save).and_return(true)
        do_post(true)
      end

      it "should redirect to ticket property index" do
        do_post(true)
        response.should be_redirect
        response.should redirect_to(admin_project_ticket_properties_path(@project))
      end      
      
    end

    describe 'with invalid attributes' do

      def do_post
        super(false)
      end
      
      it "should not save the ticket property" do
        @ticket_property_type.should_receive(:save).and_return(false)
        do_post
      end

      it_should_successfully_render_template('new', :do_post)
      
    end

  end


  describe "handling GET /admin/project_name/ticket_properties/1/edit" do
    
    before do
      @ticket_property_type = mock_model(TicketPropertyType, :to_param => '1')
      @ticket_properties.stub!(:find).and_return(@ticket_property_type)
    end

    def do_get
      get :edit, :project_id => 'retro', :id => '1'
    end      

    it_should_successfully_render_template('edit')

    it "should find the related project" do
      Project.should_receive(:find_by_short_name!).and_return(@project)
      do_get
      assigns[:project].should == @project
    end

    it "should find the ticket property" do
      @ticket_properties.should_receive(:find).with('1').and_return(@ticket_property_type)
      do_get
    end

    it "should not update the ticket property" do
      @ticket_property_type.should_not_receive(:update_attributes)
      do_get
    end

    it "should assign the ticket property for the view" do
      do_get
      assigns[:ticket_property_type].should == @ticket_property_type
    end

  end


  describe "handling PUT /admin/project_name/ticket_properties/1" do
    
    before do
      @ticket_property_type = mock_model(TicketPropertyType, :to_param => '1')
      @ticket_properties.stub!(:find).and_return(@ticket_property_type)
    end

    def do_put(success = true)
      @ticket_property_type.stub!(:update_attributes).and_return(success)
      put :update, :project_id => 'retro', :id => '1', :ticket_property_type => {}
    end      

    it "should find the related project" do
      Project.should_receive(:find_by_short_name!).and_return(@project)
      do_put
      assigns[:project].should == @project
    end

    it "should find the ticket property" do
      @ticket_properties.should_receive(:find).with('1').and_return(@ticket_property_type)
      do_put
    end

    describe 'with valid attributes' do

      it "should save the ticket property" do
        @ticket_property_type.should_receive(:update_attributes).with({}).and_return(true)
        do_put(true)
      end

      it "should redirect to ticket property index" do
        do_put(true)
        response.should be_redirect
        response.should redirect_to(admin_project_ticket_properties_path(@project))
      end      
      
    end

    describe 'with invalid attributes' do

      def do_put
        super(false)
      end
      
      it "should not save the ticket property" do
        @ticket_property_type.should_receive(:update_attributes).with({}).and_return(false)
        do_put
      end

      it_should_successfully_render_template('edit', :do_put)
      
    end

  end



  describe "handling DELETE /admin/project_name/ticket_properties/1" do
    
    before do
      @ticket_property_type = mock_model(TicketPropertyType, :to_param => '1', :destroy => true)
      @ticket_properties.stub!(:find).and_return(@ticket_property_type)
    end

    def do_delete
      delete :destroy, :project_id => 'retro', :id => '1'
    end      

    it "should find the related project" do
      Project.should_receive(:find_by_short_name!).and_return(@project)
      do_delete
      assigns[:project].should == @project
    end

    it "should delete the ticket property" do
      @ticket_properties.should_receive(:find).and_return(@ticket_property_type)
      @ticket_property_type.should_receive(:destroy).and_return(@ticket_property_type)
      do_delete
    end

    it "should redirect to ticket property index" do
      do_delete
      response.should be_redirect
      response.should redirect_to(admin_project_ticket_properties_path(@project))
    end

  end


  describe "handling PUT /admin/project_name/ticket_properties/sort" do
    
    before do
      @ticket_properties.stub!(:update_all).and_return(true)
    end
    
    def do_put
      xhr :put, :sort, :project_id => 'retro', :ticket_properties => ['3', '1', '2']        
    end

    it "should find the related project" do
      Project.should_receive(:find_by_short_name!).and_return(@project)
      do_put
      assigns[:project].should == @project
    end
    
    it "should update the records" do
      @ticket_properties.should_receive(:update_all).
        with(['rank = ?', 0], ['id = ?', 3]).and_return(true)
      @ticket_properties.should_receive(:update_all).
        with(['rank = ?', 1], ['id = ?', 1]).and_return(true)
      @ticket_properties.should_receive(:update_all).
        with(['rank = ?', 2], ['id = ?', 2]).and_return(true)
      do_put
    end

    it "should render nothing" do
      do_put
      response.should be_success
      response.body.should be_blank
    end

  end

end
