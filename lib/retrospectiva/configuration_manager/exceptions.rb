module Retrospectiva
  module ConfigurationManager  
    class Error < StandardError
    end
    class InvalidValueError < Error
    end
    class InvalidSectionError < Error
    end
    class InvalidGroupError < Error
    end
    class InvalidSettingError < Error
    end
    class InvalidDefinitionError < Error
    end
    class InvalidSettingDefinitionError < InvalidDefinitionError
    end
  end
end
