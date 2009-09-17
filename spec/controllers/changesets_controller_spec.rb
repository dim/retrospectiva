require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ChangesetsController do  
  it_should_behave_like EveryProjectAreaController

  before do
    @project = permit_access_with_current_project! :name => 'Any'
    @changesets = [mock_model(Changeset, :revision => 'R10', :log => 'L1', :author => 'A1', :created_at => 1.month.ago)]
    @proxy = @project.stub_association!(:changesets)
    @proxy.stub!(:count).and_return(5)
    @proxy.stub!(:maximum)
  end
  
  describe "handling GET /changesets" do
    before do
      @proxy.stub!(:paginate).and_return(@changesets)
    end
    
    def do_get
      get :index, :project_id => @project.to_param    
    end

    it 'should check freshness' do
      @proxy.should_receive(:count).and_return(5)
      @proxy.should_receive(:maximum).with(:created_at)
      do_get
    end
    
    it "should find the changesets" do
      do_get
      assigns[:changesets].should == @changesets
    end

    it "should find changesets" do
      @proxy.should_receive(:paginate).
        with(:per_page=>nil, :page=>nil, :total_entries=>nil, :order=>'changesets.created_at DESC', :include=>[:user]).
        and_return(@changesets)
      do_get
    end

    it_should_successfully_render_template('index')
  end

  describe "handling GET /changesets.rss" do
    before(:each) do
      Changeset.stub!(:to_rss).and_return("RSS")
      @proxy.stub!(:paginate).and_return(@changesets)
    end
    
    def do_get(options = {})
      get :index, options.merge(:format => 'rss', :project_id => @project.to_param)
    end
    
    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find changesets" do
      @proxy.should_receive(:paginate).
        with(:per_page=>10, :total_entries=>10, :page=>1, :order=>'changesets.created_at DESC', :include=>[:user]).
        and_return(@changesets)
      do_get
    end

    it "should render the found milestones as RSS" do
      Changeset.should_receive(:to_rss).with(@changesets, {}).and_return("RSS")
      do_get :completed => '1'
      response.body.should == "RSS"
      response.content_type.should == "application/rss+xml"
    end
  end

  describe "handling GET /changesets/show" do
    describe 'if the record can be found' do
      before do
        @changeset = @changesets.first
        @next_changeset = @changesets.last
        @proxy.stub!(:find_by_revision!).and_return(@changeset)
        @changeset.stub!(:next_by_project).and_return(@next_changeset)
        @changeset.stub!(:previous_by_project).and_return(nil)
        @changeset.stub!(:created_at)        
      end
      
      def do_get
        get :show, :project_id => @project.to_param, :id => '1'        
      end

      
      it "should find the changeset" do
        @proxy.should_receive(:find_by_revision!).
          with('1', :include => [:changes, :user]).and_return(@changeset)
        do_get
        assigns[:changeset].should == @changeset
      end

      it 'should check freshness' do
        @changeset.should_receive(:created_at).and_return(1.day.ago)
        do_get
      end

      it "should find the previous and next changeset" do
        @changeset.should_receive(:next_by_project).
          with(@project).and_return(@next_changeset)
        @changeset.should_receive(:previous_by_project).
          with(@project).and_return(nil)
        do_get
        assigns[:previous_changeset].should be_nil
        assigns[:next_changeset].should == @next_changeset
      end

      it_should_successfully_render_template('show')

    end

  end


  describe "handling GET /changesets/diff" do

    before do
      @changeset = @changesets.first
      @proxy.stub!(:find_by_revision!).and_return(@changeset)
      @change = mock_model(Change, :diffable? => true)
      @changes_proxy = @changeset.stub_association!(:changes, :find => @change)
    end
      
    def do_get
      get :diff, :project_id => @project.to_param, :id => @changeset.to_param, :change_id => @change.to_param        
    end
      
    it "should find the changeset" do
      @proxy.should_receive(:find_by_revision!).
        with(@changeset.to_param, :include => [:changes, :user]).and_return(@changeset)
      do_get
      assigns[:changeset].should == @changeset
    end

    it "should find the change" do
      @changes_proxy.should_receive(:find).
        with(@change.to_param).and_return(@change)
      do_get
      assigns[:change].should == @change
    end

    describe 'if change is not diffable' do
    
      it "should display a 404 page" do
        rescue_action_in_public!
        @change.should_receive(:diffable?).and_return(false)
        do_get
        response.code.should == '404'
      end

    end
    
    describe 'if change IS diffable' do

      it "should display the unified diff" do
        @change.should_receive(:diffable?).and_return(true)
        do_get
        response.should be_success
        response.should render_template(:diff)
      end
      
    end

  end

end
