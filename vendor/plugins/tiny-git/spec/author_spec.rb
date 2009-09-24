require File.dirname(__FILE__) + '/helper'


describe TinyGit::Author do
  
  def new_author(string)
    TinyGit::Author.new(string)
  end
  
  it 'should successfully parse UNIX timestamp formats' do
    r = new_author("G.M. Author <test@mail.com> 1253795000 +0100")
    r.name.should == "G.M. Author"
    r.email.should == "test@mail.com"
    r.date.should == Time.utc(2009, 9, 24, 12, 23, 20)
  end

  it 'should successfully parse RFC timestamp formats' do
    r = new_author("G.M. Author <test@mail.com> Thu, 24 Sep 2009 13:23:20 +0100")
    r.name.should == "G.M. Author"
    r.email.should == "test@mail.com"
    r.date.should == Time.utc(2009, 9, 24, 12, 23, 20)
  end   

  it 'should store no values for incorrect strings' do
    r = new_author(" --- ")
    r.name.should be_nil
    r.email.should be_nil
    r.date.should be_nil
  end   
  
end