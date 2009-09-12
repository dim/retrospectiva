require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/sprints/show.json.erb" do
  
  before(:each) do
    @time_line = ActiveSupport::OrderedHash.new
    @time_line[Date.civil(2009,7,5)] = 120
    @time_line[Date.civil(2009,7,6)] = 90
    @time_line[Date.civil(2009,7,7)] = 60
    @sprint = assigns[:sprint] = stub_model(Sprint, :time_line => @time_line)

    template.stub!(:permitted?).and_return(true)
    template.stub!(:sprint_location).and_return('#')
  end

  def json(response)
    @json ||= ActiveSupport::JSON.decode(response.body)    
  end

  it "should render the chart JSON" do
    render
    result = ActiveSupport::JSON.decode(response.body)
    json(response).keys.sort.should == ["bg_colour", "elements", "title", "x_axis", "y_axis"]    
    json(response)['y_axis'].values_at('min', 'max', 'steps').should == [0, 150, 50]
    json(response)['y_axis']['labels'].should == ["0", "50", "100", "150"]

    json(response)['x_axis']['labels']['labels'].should == ["Kick-off", "Jul 05", "Jul 06", "Jul 07"]

    json(response)['elements'].should have(1).item
    json(response)['elements'].first["values"].should == [120, 90, 60]
  end
  
end

