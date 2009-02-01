Spec::Rails::Example::FunctionalExampleGroup.class_eval do

  def self.pretend_to_be(klass)
    before :each do
      
      superclass = klass.superclass
      while @controller_class != superclass
        superclass = superclass.superclass
        raise "Invalid usage of pretend_to_be. #{klass} is not a subclass of #{@controller_class}" if superclass.nil? 
      end      
      
      @controller_class = klass
      @controller = @controller_class.new
      (class << @controller; self; end).class_eval do
        def controller_path #:nodoc:
          self.class.name.underscore.gsub('_controller', '')
        end
        include Spec::Rails::Example::ControllerExampleGroup::ControllerInstanceMethods
      end      

    end
  end

end

