module Spec::Rails
  
  module Mocks

    def stub_model(model_class, stubs={})
      stubs = {:id => next_id}.merge(stubs)
      model_class.new.tap do |model|
        model.id = stubs.delete(:id)
        model.extend ModelStubber
        stubs.each do |k,v|
          if model.has_attribute?(k)
            model[k] = stubs.delete(k)
          end
        end
        model.stub!(stubs)
        yield model if block_given?
      end
    end

  end

  class Example::HelperExampleGroup
  
    def self.helper
      @helper_object ||= HelperObject.new.tap do |helper_object|
        if @helper_being_described.nil?
          if described_type.class == Module
            helper_object.extend described_type
          end
        else
          helper_object.extend @helper_being_described
        end
      end
    end
  
  end

end

        