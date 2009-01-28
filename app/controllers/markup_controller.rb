class MarkupController < ApplicationController
  layout 'markup_reference'
  verify_action :preview, :params => [:element_id], :xhr => true

  def preview
    respond_to(:js)
  end
  
  def reference
    @examples = WikiEngine.default.markup_examples
    @examples[_('Links')] += [
      "A solution to this problem can be found\nin changeset \[712\]",
      "This problem is described in Ticket [#3733]",    
    ]
  end

end
