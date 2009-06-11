require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiHelper do
  
  describe 'creating anchors' do

    it 'should work correctly' do      
      helper.anchorize(%Q(
        <p>Some text</p>
        <h1>A Headline</h1>
        <p>More text</p>
      )).squish.should == %Q(
        <p>Some text</p>
        <h1>A Headline <a id=\"--a-headline\" href=\"#--a-headline\" class=\"wiki-anchor\">&para;</a></h1>
        <p>More text</p>      
      ).squish
    end

    it 'should keep header attributes' do      
      helper.anchorize(%Q(
        <p>Some text</p>
        <h1 class="small">A Headline</h1>
        <p>More text</p>
      )).squish.should == %Q(
        <p>Some text</p>
        <h1 class="small">A Headline <a id=\"--a-headline\" href=\"#--a-headline\" class=\"wiki-anchor\">&para;</a></h1>
        <p>More text</p>      
      ).squish
    end

    it 'should generate correct tags' do      
      helper.anchorize(%Q(
        <p>Some text</p>
        <h1 class="small">A Head &amp;<br/> Line</h1>
        <p>More text</p>
      )).squish.should == %Q(
        <p>Some text</p>
        <h1 class="small">A Head &amp;<br/> Line <a id=\"--a-head-line\" href=\"#--a-head-line\" class=\"wiki-anchor\">&para;</a></h1>
        <p>More text</p>      
      ).squish
    end

  end
end