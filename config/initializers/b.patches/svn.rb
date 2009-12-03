module Svn

  @@dirty_runs = 0
  def self.sweep_garbage!
    GC.start if (@@dirty_runs = (@@dirty_runs + 1) % 10).zero?
  end 

  module Core
    class Stream
      def close_with_manual_garbage_collection
        close_without_manual_garbage_collection
        Svn.sweep_garbage!          
      end
      alias_method_chain :close, :manual_garbage_collection
    end
  end

  module Fs
    class Root
      def copied_from_with_manual_garbage_collection(*args)
        Svn.sweep_garbage!
        copied_from_without_manual_garbage_collection(*args)
      end
      alias_method_chain :copied_from, :manual_garbage_collection
    end      
  end

end if SCM_SUBVERSION_ENABLED