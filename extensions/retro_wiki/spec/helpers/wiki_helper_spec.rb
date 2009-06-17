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
        <h1>A Headline <a id=\"A-Headline\" href=\"#A-Headline\" class=\"wiki-anchor\">&para;</a></h1>
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
        <h1 class="small">A Headline <a id=\"A-Headline\" href=\"#A-Headline\" class=\"wiki-anchor\">&para;</a></h1>
        <p>More text</p>      
      ).squish
    end

    it 'should generate clean up content' do      
      helper.anchorize(%Q(
        <p>Some text</p>
        <h1 class="small">A &quot;Head&quot; <br/> Line</h1>
        <p>More text</p>
      )).squish.should == %Q(
        <p>Some text</p>
        <h1 class="small">A &quot;Head&quot; <br/> Line <a id=\"A-Head-Line\" href=\"#A-Head-Line\" class=\"wiki-anchor\">&para;</a></h1>
        <p>More text</p>      
      ).squish
    end

  end
end