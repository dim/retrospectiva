require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::GroupsController do
  it_should_behave_like EveryAdminAreaController
  
  before do
    permit_access!
    @groups = [mock_model(Group), mock_model(Group)]
  end

  describe "handling GET /admin/groups" do

    before(:each) do
      Group.stub!(:find).and_return(@groups)
    end
  
    def do_get
      get :index      
    end
    
    it_should_successfully_render_template('index')

    it "should find group records" do
      Group.should_receive(:find).
        with(:all, :order => 'CASE groups.name WHEN \'Default\' THEN 0 ELSE 1 END, groups.name',
        :offset => 0, :limit => Group.per_page).
        and_return(@groups)
      do_get
    end

    it "should assign the found records for the view" do
      do_get
      assigns[:groups].should == @groups.paginate
    end

  end
  



  describe "handling GET /admin/groups/new" do

    before(:each) do
      @group = mock_model(Group)
      Group.stub!(:new).and_return(@group)
      Project.stub!(:find).and_return([])
    end

    def do_get
      get :new      
    end
    
    it_should_successfully_render_template('new')
  
    it "should create an new group" do
      Group.should_receive(:new).and_return(@group)
      do_get
    end
  
    it "should not save the new group" do
      @group.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new group for the view" do
      do_get
      assigns[:group].should equal(@group)
    end

    it "should pre-load the project records" do
      Project.should_receive(:find).and_return([])
      do_get
      assigns[:projects].should == []
    end
    
  end


  describe "handling GET /admin/groups/1/edit" do

    before(:each) do
      @group = mock_model(Group)
      Group.stub!(:find).and_return(@group)
      Project.stub!(:find).and_return([])
    end
  
    def do_get
      get :edit, :id => "1"      
    end
  
    it "should find the group requested" do
      Group.should_receive(:find).with('1').and_return(@group)
      do_get
    end
  
    it "should assign the found group for the view" do
      do_get
      assigns[:group].should equal(@group)
    end

    it_should_successfully_render_template('edit')

    it "should pre-load the project records" do
      Project.should_receive(:find).and_return([])
      get :new
      assigns[:projects].should == []
    end
    
  end


  describe "handling POST /admin/groups" do

    before(:each) do
      @group = mock_model(Group, :to_param => "1")
      Group.stub!(:new).and_return(@group)
      Project.stub!(:find).and_return([])
    end
    
    describe "with successful save" do
  
      def do_post
        @group.should_receive(:save).and_return(true)
        post :create, :group => {}
      end
  
      it "should create a new group" do
        Group.should_receive(:new).with({}).and_return(@group)
        do_post
      end

      it "should not pre-load the project records" do
        Project.should_not_receive(:find)
        do_post
      end

      it "should redirect to the group list" do
        do_post
        response.should redirect_to(admin_groups_path)
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @group.should_receive(:save).and_return(false)
        post :create, :group => {}
      end
  
      it_should_successfully_render_template('new', :do_post)

      it "should pre-load the project records" do
        Project.should_receive(:find).and_return([])
        get :new
        assigns[:projects].should == []
      end
      
    end
  end


  describe "handling PUT /admin/groups/1" do

    before(:each) do
      @group = mock_model(Group, :to_param => "1")
      Group.stub!(:find).and_return(@group)
      Project.stub!(:find).and_return([])
    end

    describe "with successful update" do

      def do_put
        @group.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the group requested" do
        Group.should_receive(:find).with("1").and_return(@group)
        do_put
        assigns(:group).should equal(@group)
      end

      it "should not pre-load the project records" do
        Project.should_not_receive(:find)
        do_put
      end

    end    
    
    describe "with failed update" do

      def do_put
        @group.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it_should_successfully_render_template('edit', :do_put)

      it "should pre-load the project records" do
        Project.should_receive(:find).and_return([])
        get :new
        assigns[:projects].should == []
      end
      
    end
  end


  describe "handling DELETE /groups/1" do

    before(:each) do
      @group = mock_model(Group, :to_param => "1", :destroy => true)
      Group.stub!(:find).and_return(@group)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find and destroy the group requested" do
      @group.should_receive(:destroy).and_return(true)
      do_delete
    end
  
    it "should redirect to the groups list" do
      do_delete
      response.should redirect_to(admin_groups_path)
    end
  end


end
