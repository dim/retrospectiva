module WikiEngine

  class AbstractEngine 
    def markup_examples
      examples = ActiveSupport::OrderedHash.new
      examples[_('Paragraphs')] = []
      examples[_('Headers')] = []
      examples[_('Formats')] = []
      examples[_('Blocks')] = []
      examples[_('Lists')] = []
      examples[_('Links')] = []
      examples[_('References')] = []
      examples[_('Tables')] = []
      examples
    end

    def markup
      raise "Abstract method"      
    end
  end
  
  class TextileBasedEngine < AbstractEngine
    def markup_examples
      examples = super
      examples[_('Paragraphs')] = [
        "A single paragraph\n\nFollowed by another",
        "p. A single paragraph\n\np. Followed by another",
        "p<. A left-aligned paragraph",
        "p>. A right-aligned paragraph",
        "p=. A centered paragraph",
        "p<>. A justified paragraph",
        "p(. A left idented paragraph",
        "p((. A stronger left idented paragraph",
        "p>). A right aligned & idented paragraph",
        "I spoke.\nAnd none replied\n\nI spoke. And none replied"
      ]  
      examples[_('Headers')] = [
        "h1. Header 1\n\nh2. Header 2\n\nh3. Header 3"
      ]    
      examples[_('Blocks')] = [
        "bq. A block quotation",
      ]    
      examples[_('Lists')] = [
        "# Fuel could be:\n## Coal\n## Gasoline\n## Electricity", 
        "* Fuel could be:\n** Coal\n** Gasoline\n** Electricity"
      ]    
      examples[_('Links')] = [
        "You can find Retrospectiva\nunder http://www.retrospectiva.org",
        "Please visit\n\"Retrospectiva\":http://www.retrospectiva.org\nfor more information",
      ]    
      examples[_('References')] = [
        "!http://www.retrospectiva.org/images/logo_small.png!"
      ]
      examples[_('Tables')] = [
        "| name | age | sex |\n| joan | 24 | f |\n| archie | 29 | m |\n| bella | 45 | f |",
        "|_. name |_. age |_. sex |\n| joan | 24 | f |\n| archie | 29 | m |\n| bella | 45 | f |",
        "|_. attribute list |\n|<. align left |\n|>. align right|\n|=. align center |\n|<>. align justify |\n|^. valign top |\n|~. valign bottom |",
        "|\\2. two column span |\n| col 1 | col 2 |"
      ]
      examples[_('Formats')] = [
        "strong: I *believe* every word\n\n"+ 
        "emphased: I _believe_ every word\n\n" + 
        "citation: I ??believe?? every word\n\n" +
        "inserted: I +believe+ every word\n\n" + 
        "deleted: I -believe- every word\n\n" + 
        "superscript: I ^believe^ every word\n\n" + 
        "subscript: I ~believe~ every word\n\n" + 
        "inline-code: I @believe@ every word" 
      ]      
      examples
    end    
  end


  class TextileEngine < TextileBasedEngine     
    
    def markup(text)      
      WikiEngine::RedCloth.new(text, [:sanitize_html, :filter_styles, :filter_classes, :filter_ids, :no_span_caps]).to_html
    end  
  end


  class RetroEngine < TextileBasedEngine  
    def markup_examples
      examples = super
      examples[_('Paragraphs')] += [
        "I spoke.[[BR]]And none replied"
      ]    
      examples[_('Headers')] += [
        "= Header 1 =\n\n== Header 2 ==\n\n=== Header 3 ==="
      ]    
      examples[_('Blocks')] += [
        "bc. A code block",
        "{{{\n  public String toString() {\n    this.entity.getNodeName();\n  }\n}}}"    
      ]    
      examples
    end

    def markup(text)      
      WikiEngine::Retro.new(text).to_html
    end  
  end


  class MarkDownEngine < AbstractEngine
    def markup_examples
      examples = super
      examples[_('Paragraphs')] = [
        "I spoke.\nAnd none replied\n\nI spoke. And none replied",
        "Insert two spaces at the end of the line  \nto force a line break"
      ]    
      examples[_('Headers')] = [
        "# Header 1#\n\n## Header 2##\n\n### Header 3###"
      ]
      examples[_('Formats')] = [
        "strong: I **believe** every word\n\n"+ 
        "emphased: I *believe* every word\n\n" + 
        "inline-code: I `believe` every word"
      ]
      examples[_('Links')] = [
        "An inline link to\n[Retrospectiva](http://retrospectiva.org/).",
      ]    
      examples[_('Blocks')] = [
        "> A block quotation",
        "This is a normal paragraph:\n\n    This is a code block"
      ]
      
      examples[_('Lists')] = [
        "* Fuel could be:\n  * Coal\n  * Gasoline\n  * Electricity", 
        "1. Fuel could be:\n  1. Coal\n  2. Gasoline\n  3. Electricity"
      ]    
      examples
    end

    def markup(text)      
      RDiscount.new(text).to_html
    end  
  end

  
  class RDocEngine < AbstractEngine
    def markup_examples
      examples = super

      examples[_('Headers')] = [
        "= Header 1\n\n== Header 2\n\n=== Header 3"
      ]
      examples[_('Formats')] = [
        "strong: I *believe* every word",
        "emphased: I _believe_ every word"
      ]
      examples[_('Links')] = [
        "You can find Retrospectiva\nunder http://www.retrospectiva.org",
      ]
      examples[_('Lists')] = [
        "* Fuel could be:\n  * Coal\n  * Gasoline\n  * Electricity", 
        "Fuel could be:\n1. Coal\n2. Gasoline\n3. Electricity"
      ]
      examples
    end

    def markup(text)      
      WikiEngine::RDoc.new(text).to_html
    end
  end

end



  