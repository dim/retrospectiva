require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiEngine do  
    
  def match(text)
    text.match(WikiEngine.wiki_word_pattern).to_a[-4..-1]
  end 
     
  def parse(text)
    m = text.match(WikiEngine.wiki_word_pattern)
    WikiEngine.parse_wiki_word_link(m) do |*args|
      args
    end
  end

  describe 'matching' do    

    it 'should match simple links' do
      match("A [[Page]] link").to_a.should == [nil, 'Page', nil, nil]
    end
  
    it 'should match links with custom titles' do
      match("this is a [[Page:Title]] link").should == [nil, 'Page', 'Title', nil]
    end
  
    it 'should match image/file links' do
      match("this is a [[I:Name]] link").should == ["I", "Name", nil, nil]
      match("this is a [[F:Name]] link").should == ["F", "Name", nil, nil]
    end
  
    it 'should match image/file links with title' do
      match("this is a [[I:Name:AltText]] link").should == ["I", "Name", "AltText", nil]
      match("this is a [[F:Name:Title]] link").should == ["F", "Name", "Title", nil]
    end
  
    it 'should NOT match other links' do
      match("this is a [[X:Name]] link").should == nil
    end

    it 'should match sizes if correct' do
      match("An [[I:Image:300x250]] with size").should == ["I", "Image", nil, '300x250']
      match("An [[I:Image:Name:300x250]] with size").should == ["I", "Image", "Name", '300x250']
      match("An [[I:Image:Name:300&#215;250]] with size").should == ["I", "Image", "Name", '300&#215;250']
    end

    it 'should NOT match sizes if not correct' do
      match("An [[I:Image:300xA1]] with size").should == nil
    end

  end

  describe 'parsing' do    

    it 'should use simple links' do
      parse("this is a [[Page]] link").should == [nil, 'Page', 'Page', nil]
    end
  
    it 'should use links with custom titles' do
      parse("this is a [[Page:Title]] link").should == [nil, 'Page', 'Title', nil]
    end
  
    it 'should use preview links' do
      parse("this is a [[\\Page:Title]] link").should == '[[Page:Title]]'
    end
  
    it 'should use image/file links' do
      parse("this is a [[I:Name]] link").should == ["I", "Name", "Name", nil]
      parse("this is a [[F:Name]] link").should == ["F", "Name", "Name", nil]
    end
  
    it 'should use image/file links with title' do
      parse("this is a [[I:Name:AltText]] link").should == ["I", "Name", "AltText", nil]
      parse("this is a [[F:Name:Title]] link").should == ["F", "Name", "Title", nil]
    end
  
    it 'should use image/file preview links' do
      parse("this is a [[I:\\Name:AltText]] link").should == "[[I:Name:AltText]]"
      parse("this is a [[F:\\Name:Title]] link").should == "[[F:Name:Title]]"
    end

    it 'should parse images with sizes' do
      parse("An [[I:Image:300x250]] with size").should == ["I", "Image", "Image", '300x250']
      parse("An [[I:Image:Name:300x250]] with size").should == ["I", "Image", "Name", '300x250']
      parse("An [[I:Image:Name:300&#215;250]] with size").should == ["I", "Image", "Name", '300x250']
    end
  
  end

  
end