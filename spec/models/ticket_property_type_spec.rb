require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketPropertyType do

  describe 'an instance' do
    fixtures :ticket_property_types

    before do
      @ticket_property_type = ticket_property_types(:retro_release)      
    end
    
    it "should fake a class name to act like global property types" do
      @ticket_property_type.class_name.should == 'Release'
    end

    it "should not be a global type" do
      @ticket_property_type.should_not be_global
    end

    it "should have many properties" do
      @ticket_property_type.should have_many(:ticket_properties)
    end

    it "should belong to a project" do
      @ticket_property_type.should belong_to(:project)
    end
    
  end


  describe 'on save' do

    before do
      @ticket_property_type = TicketPropertyType.new
    end

    it "should validate presence of project" do
      @ticket_property_type.should validate_presence_of(:project_id)
    end

    it "should validate presence of name" do
      @ticket_property_type.should validate_presence_of(:name)
    end

    it "should validate uniqueness of name" do
      @ticket_property_type.should validate_uniqueness_of(:name)
    end

    it "should validate length of name (2-20 characters)" do
      @ticket_property_type.should validate_length_of(:name, :within => 2..20)
    end

    it "should validate format of name" do
      @ticket_property_type.name = 'invalid:name'
      @ticket_property_type.should have(1).error_on(:name)
      @ticket_property_type.name = 'Valid Name'
      @ticket_property_type.should have(:no).errors_on(:name)
    end
    
  end
end
