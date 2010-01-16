require File.dirname(__FILE__) + '/spec_helper.rb'

describe Retro::Search do

  def search(string)
    @search ||= Retro::Search.new(string)
  end
  
  describe 'parsing search strings' do    
    it 'should extract word tokens' do
      s = search('first second third') 
      s.words.should have(3).records
      s.words.should == %w(first second third)
    end

    it 'should extract phrase tokens' do
      s = search('"first phrase" "second phrase"')
      s.phrases.should have(2).records
      s.phrases.should == ["first phrase", "second phrase"]
    end

    it 'should extract a mix of words and phrases' do
      s = search('first "first phrase" second "second phrase" third')
      s.tokens.should have(5).records
      s.words.should have(3).records
      s.phrases.should have(2).records
      s.words.should == %w(first second third)
      s.phrases.should == ["first phrase", "second phrase"]
    end

    it 'should identify the incusion/exclusion status of word tokens' do
      s = search('+first -second third -"first phrase"')
      s.tokens.should have(4).records
      s.tokens.should == ['first', 'second', 'third', 'first phrase']
      s.tokens.map(&:method_code).should == [:i, :x, :i, :x]
    end

    it 'should only check for incusion/exclusion at the beginning of a token' do
      s = search('first+ --second ++third "-first phrase" "second-phrase++"')
      s.tokens.should have(5).records
      s.tokens.should == ['first+', '-second', '+third', 'first phrase', 'second-phrase++']
      s.tokens.map(&:method_code).should == [:i, :x, :i, :x, :i]
    end    
  end
  
  describe 'generating SQL clauses' do
    
    def search(string = nil)
      super(string || '+first -"seCONd phrAse" third')
    end
    
    before do
      @columns = ['a.column1', 'a.column2', 'b.column1']
      @expected_clause = [
        "(LOWER(a.column1) LIKE ? OR LOWER(a.column2) LIKE ? OR LOWER(b.column1) LIKE ?)",
        "(LOWER(a.column1) LIKE ? OR LOWER(a.column2) LIKE ? OR LOWER(b.column1) LIKE ?)",
        "(LOWER(a.column1) NOT LIKE ? AND LOWER(a.column2) NOT LIKE ? AND LOWER(b.column1) NOT LIKE ?)"
      ]
      @expected_bindings = [
        '%first%', '%first%', '%first%',
        '%third%', '%third%', '%third%',
        '%second phrase%', '%second phrase%', '%second phrase%'
      ]      
    end
    
    it 'should generate the correct clause for the given input' do
      search.statement(*@columns).should == @expected_clause.join(' AND ')
    end

    it 'should generate the correct binding variables' do
      search.variables(*@columns).should == @expected_bindings
    end

    it 'should generate the correct binding variables' do
      search.to_a(*@columns).should == [@expected_clause.join(' AND '), *@expected_bindings]
    end
  
  end

  describe 'handling ID columns' do
    before do
      @s = search('+2 -1')
      @columns = ['a.column', 'b.id', 'c.foreign_id', '@d.my_num']
      @expected_clause =
        "(LOWER(a.column) LIKE ? OR b.id = ? OR c.foreign_id = ? OR d.my_num = ?) AND " +
        "(LOWER(a.column) NOT LIKE ? AND b.id <> ? AND c.foreign_id <> ? AND d.my_num <> ?)"
      @expected_bindings = [
        '%2%', 2, 2, 2,
        '%1%', 1, 1, 1
      ]      
    end
    
    it 'should generate the correct cause for the given input' do
      @s.statement(*@columns).should == @expected_clause
    end

    it 'should generate the correct binding variables' do
      @s.variables(*@columns).should == @expected_bindings
    end

    it 'should generate the correct binding variables' do
      @s.to_a(*@columns).should == [@expected_clause, *@expected_bindings]
    end
  end
  
end