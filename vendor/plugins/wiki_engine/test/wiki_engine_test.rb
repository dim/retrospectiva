# encoding:utf-8
require File.dirname(__FILE__) + '/helper' 

class WikiEngineTest < Test::Unit::TestCase

  def test_default_engine_assignment
    assert_raise(RuntimeError) { WikiEngine.default_engine = 'invalid' }    

    present = WikiEngine.supported_engine_names - ['retro']
    unless present.empty? #skip test
      WikiEngine.default_engine = present.first
      assert_equal(WikiEngine.default_engine, WikiEngine.supported_engines[present.first])                
    end
    
    missing = WikiEngine.supported_engines.stringify_keys.keys - WikiEngine.supported_engine_names 
    unless missing.empty? #skip test
      WikiEngine.default_engine = missing.first
      assert_equal(WikiEngine.default_engine, WikiEngine.supported_engines['retro'])                
    end
    
  end

  def test_select_engine
    assert_equal WikiEngine.send(:select_engine, 'invalid'), WikiEngine.supported_engines['retro']

    present = WikiEngine.supported_engine_names - ['retro']
    unless present.empty? #skip test
      assert_equal WikiEngine.send(:select_engine, present.first), WikiEngine.supported_engines[present.first]                
    end
  end

end
