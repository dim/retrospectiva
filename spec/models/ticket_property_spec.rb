require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketProperty do
  
  before do
    @ticket_property = TicketProperty.new
  end


  describe 'an instance' do
    
    it "should have and belong to many tickets" do
      @ticket_property.should have_and_belong_to_many(:tickets)
    end

    it "should belong to property type" do
      @ticket_property.should belong_to(:ticket_property_type)
    end

  end


  describe 'on save' do

    it "should validate presence of type" do
      @ticket_property.should validate_presence_of(:ticket_property_type_id)
    end

    it "should validate presence of name" do
      @ticket_property.should validate_presence_of(:name)
    end

    it "should validate uniqueness of name" do
      @ticket_property.should validate_uniqueness_of(:name)
    end

    it "should validate length of name (2-20 characters)" do
      @ticket_property.should validate_length_of(:name, :within => 2..20)
    end
            
  end


  describe 'on create' do

    it "should assign a rank" do
      @ticket_property.valid?
      @ticket_property.rank.should == 9999
    end
            
  end


end
