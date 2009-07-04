Spec::Rails::Example::ControllerExampleGroup.class_eval do
  
  class << self

    def it_should_successfully_render_template(name, method = :do_get)
      it "should be successful" do
        send(method)
        response.should be_success
      end

      it "should render the '#{name}' template" do
        send(method)
        response.should render_template(name)
      end
    end

  end

end

