class MarkupController < ApplicationController
  layout 'markup_reference'
  verify :params => [:element_id], :xhr => true, :only => :preview

  def preview
    respond_to(:js)
  end
  
  def reference
    @examples = WikiEngine.default_engine.markup_examples
    @examples[_('Links')] += [
      "A solution to this problem can be found\nin changeset \[712\]",
      "This problem is described in Ticket [#3733]",    
    ]
  end

end
