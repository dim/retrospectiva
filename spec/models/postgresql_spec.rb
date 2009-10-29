require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "PostgreSQL" do
  fixtures :all

  describe 'complex pagination' do
    
    it 'should work correctly' do      
      result = projects(:retro).tickets.paginate :page => nil,
        :per_page => 1,
        :include => Ticket.default_includes,
        :order => Milestone.reverse_order
      result.should have(1).record
    end
    
  end

end
