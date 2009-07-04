module Spec
  module Mocks
    module Methods

      def stub_association!(association_name, methods_to_be_stubbed = {}, &block)
        proxy = Spec::Mocks::Mock.new("#{association_name.to_s.classify}AssociationProxy")
        self.stub!(association_name).and_return(proxy)
        methods_to_be_stubbed.each do |method, return_value|
          proxy.stub!(method).and_return(return_value)
        end
        yield proxy if block_given?
        proxy
      end

    end
  end
end