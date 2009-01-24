require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  fixtures :groups, :groups_users, :groups_projects, :projects, :users
  
  describe 'on class level' do
    it "should be able to find the default group" do
      Group.default_group.should == groups(:Default)
    end
  end

  
  describe 'in general' do
    it "should have and belong to many users" do
      groups(:Default).should have_and_belong_to_many(:users)
      groups(:Default).users.should have(3).records
    end

    it "should have and belong to many projects" do
      groups(:Default).should have_and_belong_to_many(:projects)
      groups(:Default).projects.should have(1).records      
    end
    
    it 'should be able to present a list of assigned project names' do
      groups(:all_projects).project_names.should == ['All']
      groups(:Default).project_names.should == ['Retrospectiva']      
    end
    
    it 'should be able to present a list of assigned permission names' do
      groups(:Default).permission_names.should == [
        ["Changesets", ["View"]], 
        ["Code", ["Browse"]], 
        ["Content", ["Search"]], 
        ["Milestones", ["View"]], 
        ["Tickets", ["Create", "Update", "View", "Watch"]]
      ]
    end

    it 'should be able to check for a specific permission' do
      groups(:Default).permitted?(:tickets, :watch).should be(true)
      groups(:Default).permitted?(:tickets, :delete).should be(false)
      groups(:Default).permitted?(:tickets, :invalid).should be(false)
      groups(:Default).permitted?(:invalid, :invalid).should be(false)
    end
  end


  describe 'on save' do
    before { @group = Group.new } 

    it "should validate presence of name" do
      @group.should validate_presence_of(:name)
    end

    it "should validate length of name (3-40 characters)" do
      @group.should validate_length_of(:name, :within => 3..40)
    end

    it "should validate format of name (only alphanumerics)" do
      @group.name = 'Group*Name'
      @group.should have(1).error_on(:name)
    end

    it "should validate uniqueness of name" do
      @group.should validate_uniqueness_of(:name)
    end

    it "should validate presence of at least permission" do
      @group.should have(1).error_on(:permissions)
    end

    it "should automatically remove blank permission names" do
      @group.permissions = { 'tickets'  => ['view', 'create', ' ', ''] } 
      @group.valid?
      @group.permissions.should == { 'tickets'  => ['create', 'view'] }
    end

    it 'should not allow to modify the default group' do
      groups(:Default).name = 'Other'
      groups(:Default).should have(1).error_on(:base)
    end
    
    describe 'if access-to-all-projects is selected' do
      before do
        @group.attributes = { 
          :permissions => {'tickets' => 'view'}, 
          :name => 'New Group', 
          :access_to_all_projects => true }
        @group.save.should be(true)
        @group.permissions.should == { 'tickets' => ['view'] }
      end
      
      it 'should automatically associate all existing projects with the group' do
        @group.projects.should have(3).records
      end      
    end    
  end
  
  describe 'on destroy, if group is default' do
    it 'should prevent the group from being destroyed' do
      groups(:Default).destroy.should be(false)
    end
    it 'should add an error message' do
      groups(:Default).destroy.should be(false)
      groups(:Default).errors.on(:base).should match(/cannot be deleted/)
    end
  end

end
