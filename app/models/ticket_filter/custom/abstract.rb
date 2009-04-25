class TicketFilter::Custom::Abstract
  Item = Struct.new(:id, :name)  

  def name
    self.class.name.demodulize.underscore      
  end
  
  def items
    []
  end
  
  def options
    {}
  end
  
end
