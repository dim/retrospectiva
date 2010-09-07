require File.dirname(__FILE__) + '/../../spec_helper'

describe "/changesets/index.html.erb" do

  before do 
    template.stub!(:auto_discover_feed)

    @project = stub_current_project!    
    @user = mock_model(User, :email => 'me@home', :name => 'DD')
    
    @changesets = [
      mock_model(Changeset,
        :revision => 'REV1',
        :short_revision => 'REV1',
        :author => 'dim',
        :log => 'log',
        :created_at => Date.today.to_time,
        :user => @user),
      mock_model(Changeset)
    ]
    
    assigns[:changesets] = @changesets.paginate(:per_page => 1)
  end
   
  it 'should display the changesets with links to show' do
    render '/changesets/index'
    response.should have_tag('div.changeset') do
      with_tag('h3 a[href=?]', project_changeset_path(@project, @changesets.first), /REV1/)
      with_tag('h6', 'dim')
    end
  end

  it 'should try to render the gravatar images' do
    template.should_receive(:author_gravatar).with(@user, 'dim').once.and_return('')
    render '/changesets/index'
  end

  it 'should display the pagination' do
    render '/changesets/index'
    response.should have_tag('div.pagination') do
      with_tag 'a[href=?]', project_changesets_path(@project, :page => 2)
    end
  end

end