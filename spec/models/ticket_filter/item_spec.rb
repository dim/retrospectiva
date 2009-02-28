require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe TicketFilter::Item do

  def new_item(selected_ids = [], options = {})
    TicketFilter::Item.new('priorities', @priorities, selected_ids, options)
  end
  
  before do
    @priorities = [mock_model(Priority, :name => 'Pr1', :id => 1), mock_model(Priority, :name => 'Pr2', :id => 2)]
  end

  it 'should have a name' do
    new_item.name.should == 'priorities'
  end

  it 'should store the records' do
    new_item.should == @priorities
  end
  
  it 'should have a label' do
    new_item.label.should == 'Priorities'
    new_item([], :label => 'Custom').label.should == 'Custom'
  end

  it 'should parse selected IDs' do
    new_item.selected_ids.should == []
    new_item([2]).selected_ids.should == [2]
    new_item([1, 2]).selected_ids.should == [1, 2]
    new_item([2, 1]).selected_ids.should == [2, 1]
    new_item([1, 2, 3]).selected_ids.should == [1, 2]
  end
    
  it 'should indicate if selected at all' do
    new_item.should_not be_selected
    new_item([1]).should be_selected
  end
    
  it 'should be able to tell if an ID is included' do
    new_item.include?(1).should be(false)
    new_item([1]).include?(1).should be(true)
  end

  it 'should accept additional items to be selected' do
    item = new_item([1])
    item.selected_ids.should == [1]
    item.select(2,3,4)
    item.selected_ids.should == [1, 2]
  end

  describe 'conditions' do

    it 'should accept condition options as strings' do
      item = new_item([1], :conditions => 'table.column_name IN (?)')
      item.conditions.should == ['table.column_name IN (?)', [1]]
    end

    it 'should accept condition options as procs' do
      proc = lambda {|i,c| c << ['table.column_name = ?', 1] }
      
      item = new_item([1], :conditions => proc)
      item.conditions.should == ['( table.column_name = ? )', 1]
    end
    
    
  end

end
