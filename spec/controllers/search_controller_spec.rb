require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchController do
  it_should_behave_like EveryProjectAreaController

  before do
    @project = permit_access_with_current_project! :name => 'Retrospectiva'
    @user = stub_current_user! :has_access? => true
  end

  describe 'GET /index' do    
    
    def do_get(options = {})
      get :index, options.merge(:project_id => @project.to_param)
    end

    it 'should load the available channels' do
      do_get
      assigns[:channels_index].should be_instance_of(ActiveSupport::OrderedHash)
      assigns[:channels_index].keys.should_not be_blank
      assigns[:channels_index].keys.first.should be_instance_of(Retrospectiva::Previewable::Channel)
    end

    it_should_successfully_render_template('index')
    
    describe 'if a search query is given' do

      before do
        @proxy = mock('ModelProxy', :full_text_search => [])
        @klasses = Retrospectiva::Previewable.klasses.select(&:searchable?)
      end

      it 'should query results' do
        controller.should_receive(:query_results).and_return([])
        do_get(:q => 'search term')
        assigns[:results].should == []
      end

      it 'should query each class individually' do
        @klasses.each do |klass|
          @project.should_receive(klass.name.tableize).and_return(@proxy)
        end
        @proxy.should_receive(:full_text_search).exactly(@klasses.size).times.and_return([])
        do_get(:q => 'search term', :all => '1')
        assigns[:results].should == []
      end
      
      it 'should query only selected classes' do        
        @project.should_receive(:tickets).and_return(@proxy)
        @proxy.should_receive(:full_text_search).once.and_return([])
        do_get(:q => 'search term', :tickets => '1')
        assigns[:results].should == []
      end

    end
    
    describe 'if a search query is NOT given' do
    

      it 'should NOT query results' do
        controller.should_not_receive(:query_results)
        do_get
        assigns[:results].should == []
      end
      
    end
    
  end
end
