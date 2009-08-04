# encoding:utf-8
#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++


$: << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'
require File.dirname(__FILE__) + '/../init'
require 'wiki_engine/redcloth'

class WikiEngineTest < Test::Unit::TestCase


  def test_basic
    text = 'h2. Lorem ipsum

Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut pulvinar mauris sed lorem.
Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra. 

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
Nunc sem lectus, consectetuer a, volutpat eu, pretium ac, nisl. Sed vitae augue.
Sed sit amet velit. Integer lobortis magna. Cras odio.'

    html = "<h2>Lorem ipsum</h2>
<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut pulvinar mauris sed lorem.
Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>
<p>Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
Nunc sem lectus, consectetuer a, volutpat eu, pretium ac, nisl. Sed vitae augue.
Sed sit amet velit. Integer lobortis magna. Cras odio.</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)      
  end

  def test_advanced
    text = 'h2. Lorem ipsum

Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut pulvinar mauris sed lorem.

* One
* Two 

Cum +sociis+ natoque *penatibus* et magnis _dis_ parturient montes.'

    html = "<h2>Lorem ipsum</h2>
<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut pulvinar mauris sed lorem.</p>
<ul>
\t<li>One</li>
\t<li>Two</li>
</ul>
<p>Cum <ins>sociis</ins> natoque <strong>penatibus</strong> et magnis <em>dis</em> parturient montes.</p>"

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

    html = "<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. <br/>
Ut pulvinar sed .</p>"

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
<pre><code>consectetuer adipiscing elit. Ut pulvinar mauris sed lorem.</code></pre>
<p>Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>
<p>Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.</p>
<pre><code>Nunc sem lectus, consectetuer a, volutpat eu, pretium ac, nisl. Sed vitae augue.</code></pre>
<p>Sed sit amet velit. Integer lobortis magna. Cras odio.</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end

  def test_spacing_in_code_parts
    text = %Q(Some introduction:

{{{
ruby script/server -e production
}}}
)
    html = "<p>Some introduction:</p>
<pre><code>ruby script/server -e production</code></pre>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end

  def test_correct_whitespaces_in_code_parts
    text = %Q(Some introduction {{{  
 Baud Rate: 9600
Parity Bit: even
    }}}
)
    html = "<p>Some introduction</p>
<pre><code> Baud Rate: 9600\nParity Bit: even</code></pre>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end

  def test_inline_code_parts
    text = %Q(Some introduction and then {{{    
inline:
  code
}}}
)
    html = "<p>Some introduction and then</p>
<pre><code>inline:
  code</code></pre>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end


  def test_code_escaping
    text = 'Intro:
{{{
<html>

<head>
  <script>
    // Evil Code
  </script>
</head>

<body></body>

</html>
}}}
'

    html = "<p>Intro:</p>
<pre><code>&lt;html&gt;

&lt;head&gt;
  &lt;script&gt;
    // Evil Code
  &lt;/script&gt;
&lt;/head&gt;

&lt;body&gt;&lt;/body&gt;

&lt;/html&gt;</code></pre>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end


  
  def test_br_handling
    text='Lorem ipsum[[BR]]dolor sit amet.'
    markup = WikiEngine.markup(text, 'retro')    
    assert_equal('<p>Lorem ipsum<br />dolor sit amet.</p>', markup)
  end


  
  def test_object_itself_remains_unchanged
    text = 'Lorem ipsum<br/>dolor � sit amet.'
    original = text.dup
    WikiEngine.markup(text, 'retro')
    assert_equal(original, text)
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
<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut pulvinar mauris sed lorem. 
Phasellus non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>
<h3>Cum sociis natoque</h3>
<p>Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. 
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
<p>Phasellus non [[dolor]]. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end


  def test_wiki_links_at_beginning
    text = 'Lorem ipsum dolor sit amet. 

[[Phasellus]] non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra. 
'
    html = "<p>Lorem ipsum dolor sit amet.</p>
<p>[[Phasellus]] non dolor. Vestibulum sodales fringilla eros. Pellentesque viverra.</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end






  def test_wiki_refs
    text = 'I am crazy about "Retrospectiva":retrospectiva
    
[retrospectiva]http://retrospectiva.org       
'
    html = "<p>I am crazy about <a href=\"http://retrospectiva.org\">Retrospectiva</a></p>\n"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end




  def test_security
    text = "
p>. Right aligned line\n
p<(((. Left aligned and indented line\n
p<(). IF A < B THEN B > A\n
<font size=\"100\">Test</font>\n
<font size=100>Test</font>\n
<font size='100'>Test</font>\n
<font>Test</font>\n
p<<iframe src=http://ha.ckers.org/scriptlet.html(. A nasty hack?\n
<iframe src=http://ha.ckers.org/scriptlet.html <\n
"

    html = "<p style=\"text-align:right;\">Right aligned line</p>
<p style=\"padding-left:3em;text-align:left;\">Left aligned and indented line</p>
<p style=\"padding-left:1em;padding-right:1em;text-align:left;\">IF A &lt; B THEN B &gt; A</p>
<p>Test</p>
<p>Test</p>
<p>Test</p>
<p>Test</p>
<p>p&lt;&lt;iframe src=http://ha.ckers.org/scriptlet.html(. A nasty hack?</p>
<p>&lt;iframe src=http://ha.ckers.org/scriptlet.html &lt;</p>"

    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end

  def test_correct_html_escaping
    text = "p>. Right \"aligned\" line\n"
    html = "<p style=\"text-align:right;\">Right &#8220;aligned&#8221; line</p>"
    markup = WikiEngine.markup(text, 'retro')    
    assert_equal(html, markup)
  end


  def test_extracting_text_parts
    original = "<p>Extract me</p><pre>Ignore me</pre><p class=\"ignore-me\">Extract me too</p>"
    source   = original.dup
    
    result   = WikiEngine.with_text_parts_only(source) do |match|
      match.gsub(/me/, 'ME')
    end

    assert_equal("<p>Extract ME</p><pre>Ignore me</pre><p class=\"ignore-me\">Extract ME too</p>", result)
    assert_equal(original, source)
  end

end
