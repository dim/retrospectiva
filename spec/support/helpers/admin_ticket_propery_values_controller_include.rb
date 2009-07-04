module AdminTicketProperyValuesControllerInclude

  def it_should_find_the_related_project(method = :do_get)
    Project.should_receive(:find_by_short_name!).and_return(@project)
    send(method)
    assigns[:project].should == @project
  end
  
  def it_should_find_the_property_type(method = :do_get)
    @property_types.should_receive(:find).with('1', :include=>[:ticket_properties]).and_return(@property_type)
    send(method)
    assigns[:property_type].should == @property_type
  end  

end