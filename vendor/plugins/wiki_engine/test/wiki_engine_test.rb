#--
# Copyright (C) 2006 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++

require 'rubygems'
require 'test/unit'
require File.dirname(__FILE__) + '/../init'

class WikiEngineTest < Test::Unit::TestCase


  def test_basic
    text = 'h2. Lorem ipsum

Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut pulvinar mauris sed lorem. 
Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra. 

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. 
Nunc sem lectus, consectetuer a, volutpat eu, pretium ac, nisl. Sed vitae augue. 
Sed sit amet velit. Integer lobortis magna. Cras odio.'

    html = "<h2>Lorem ipsum</h2>
\n\t<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut pulvinar mauris sed lorem. 
Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>
\n\n\t<p>Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. 
Nunc sem lectus, consectetuer a, volutpat eu, pretium ac, nisl. Sed vitae augue. 
Sed sit amet velit. Integer lobortis magna. Cras odio.</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)      
  end




  def test_html_code_removal
    text = 'Lorem ipsum dolor 
  <script> 
    this.location.href = "http://www.myspampage.com"
  </script> 
sit amet, <span style="color:red;">consectetuer</span> adipiscing elit. <br/>
Ut pulvinar <frame>mauris</frame> sed <iframe>lorem</iframe>.'

    html = "<p>Lorem ipsum dolor</p>
\n\n\t<p>sit amet, consectetuer adipiscing elit. 
Ut pulvinar  sed .</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  
  end





  def test_code_parts
    text = 'Lorem ipsum dolor sit amet. 
{{{
consectetuer adipiscing elit. Ut pulvinar mauris sed lorem.
}}}
Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra. 

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
{{{Nunc sem lectus, consectetuer a, volutpat eu, pretium ac, nisl. Sed vitae augue.}}}
Sed sit amet velit. Integer lobortis magna. Cras odio.'

    html = "<p>Lorem ipsum dolor sit amet.</p>
\n\n\t<pre><code>consectetuer adipiscing elit. Ut pulvinar mauris sed lorem.</code></pre>
\n\n\t<p>Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>
\n\n\t<p>Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.</p>
\n\n\t<pre><code>Nunc sem lectus, consectetuer a, volutpat eu, pretium ac, nisl. Sed vitae augue.</code></pre>
\n\n\t<p>Sed sit amet velit. Integer lobortis magna. Cras odio.</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end




  
  def test_br_handling
    text='Lorem ipsum[[BR]]dolor sit amet.'
    markup = WikiEngine.markup(text, 'retro')    
    assert_equal('<p>Lorem ipsum<br/>dolor sit amet.</p>', markup)
  end





  def test_object_itself_remains_unchanged
    text='Lorem ipsum<br/>dolor � sit amet.'
    markup = WikiEngine.markup(text, 'retro')
    assert_equal('Lorem ipsum<br/>dolor � sit amet.', text)
  end





  def test_media_wiki_headers
    text = 'h2. Lorem ipsum

Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut pulvinar mauris sed lorem. 
Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra.

=== Cum sociis natoque ===
Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. 
Nunc sem lectus, consectetuer a, volutpat eu, pretium ac, nisl. Sed vitae augue. 
Sed sit amet velit. Integer lobortis magna. Cras odio.'

    html = "<h2>Lorem ipsum</h2>

\t<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut pulvinar mauris sed lorem. 
Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>


\t<h3>Cum sociis natoque</h3>

\t<p>Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. 
Nunc sem lectus, consectetuer a, volutpat eu, pretium ac, nisl. Sed vitae augue. 
Sed sit amet velit. Integer lobortis magna. Cras odio.</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)      
  end





  def test_wiki_links
    text = 'Lorem ipsum dolor sit amet. 

Phasellus non [[dolor]]. Vestibulum sodales fringilla eros. Pellentesque viverra. 
'
    html = "<p>Lorem ipsum dolor sit amet.</p>
\n\n\t<p>Phasellus non [[dolor]]. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end






  def test_wiki_links_at_beginning
    text = 'Lorem ipsum dolor sit amet. 

[[Phasellus]] non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra. 
'
    html = "<p>Lorem ipsum dolor sit amet.</p>
\n\n\t<p>[[Phasellus]] non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end






  def test_wiki_refs
    text = 'I am crazy about "Retrospectiva":retrospectiva
    
[retrospectiva]http://retrospectiva.org       
'
    html = '<p>I am crazy about <a href="http://retrospectiva.org">Retrospectiva</a></p>'

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end




  def test_security
    text = "
p>. Right aligned line\n
p<(((. Left aligned and indented line\n
p<(). IF A<B THEN B > A\n
<font size=\"100\">Test</font>\n
<font size=100>Test</font>\n
<font size='100'>Test</font>\n
<font>Test</font>\n
p<<iframe src=http://ha.ckers.org/scriptlet.html(. A nasty hack?\n
<iframe src=http://ha.ckers.org/scriptlet.html <\n
"

    html = "<p style=\"text-align:right;\">Right aligned line</p>
\n\t<p style=\"padding-left:3em;text-align:left;\">Left aligned and indented line</p>
\n\t<p style=\"padding-left:1em;padding-right:1em;text-align:left;\">IF A&lt;B THEN B &gt; A</p>
\n\t<p>Test</p>
\n\n\t<p>Test</p>
\n\n\t<p>Test</p>
\n\n\t<p>Test</p>
\n\n\t<p>p&lt;&lt;</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end

  def test_correnct_html_escaping
    text = "p>. Right \"aligned\" line\n"
    html = "<p style=\"text-align:right;\">Right &#8220;aligned&#8221; line</p>"
    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end

end
