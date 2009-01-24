MarkupController.class_eval do

  def reference_with_retro_wiki_extension
    reference_without_retro_wiki_extension
    @examples[_('Links')].unshift(
      "Make a link to [[Another page]] in the\nWiki by enclosing it in double-brackets.",
      "Another [[The real page name:example]]\nfor internal Wiki page references.",
      "Use a backslash to escape [[\\Wiki]] links."
    ) 
    @examples[_('References')] += [
      "Uploaded image: [[I:Logo:Alt Text]]",
      "Download an [[F:Document:uploaded file]]",
    ]
  end  
  alias_method_chain :reference, :retro_wiki_extension

end
