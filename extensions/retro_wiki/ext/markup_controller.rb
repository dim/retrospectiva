MarkupController.class_eval do

  def reference_with_retro_wiki_extension
    reference_without_retro_wiki_extension
    @examples[_('Links')].unshift(
      "Make a link to [[Another page]] in the\nWiki by enclosing it in double-brackets.",
      "Another [[The real page name:example]]\nfor internal Wiki page references.",
      "Use a backslash to escape [[\\Wiki]] links."
    ) 
    @examples[_('References')] += [
      "Uploaded image:<br/> [[I:Logo:Optional Alt Text]]",
      "Resized image:<br/> [[I:Logo:Optional Alt Text:45x7]]",
      "Download an [[F:Document:Custom Document]]",
    ]
  end  
  alias_method_chain :reference, :retro_wiki_extension

end
