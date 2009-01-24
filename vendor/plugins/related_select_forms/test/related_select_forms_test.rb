require 'test/unit'

require 'rubygems'
require 'action_controller'
require 'action_view'

require File.dirname(__FILE__) + '/../init'

Select = Struct.new(:value) 
O = Struct.new(:id, :name, :parent_id) 

class TestController < ActionController::Base
end

class RelatedSelectFormsTest < Test::Unit::TestCase

  def setup
    @helper = ActionView::Base.new(nil, {}, TestController.new)    
  end

  def test_valid_output_for_three_selects
    # create collection structure
    #   
    #       A               B
    #   |---|---|       |---|---|
    #   K       L       M       N
    # |---|     |     |---| 
    # U   V     W     X   Y
    #   
    @collection1 = [ O.new(1, 'A'), O.new(2, 'B')]
    @collection2 = [ O.new(11, 'K', 1), O.new(12, 'L', 1), O.new(21, 'M', 2), O.new(22, 'N', 2) ]
    @collection3 = [ O.new(111, 'U', 11), O.new(112, 'V', 11), O.new(121, 'W', 12), O.new(211, 'X', 21), O.new(212, 'Y', 21) ]
    @helper.instance_variable_set(:@select3, Select.new(211)) # Select X

    html = @helper.collection_select(:select1, :value, @collection1, :id, :name) +
        @helper.related_collection_select(:select2, :value, [:select1, :value], @collection2, :id, :name, :parent_id) +
          @helper.related_collection_select(:select3, :value, [:select2, :value], @collection3, :id, :name, :parent_id)
    goal = {
      :select1_value => {:options => ids_of(@collection1, :id), :pre_selected => '2'},
      :select2_value => {:parent => :select1_value, :options => ids_of(@collection2, :id), :pre_selected => '21'},
      :select3_value => {:parent => :select2_value, :options => ids_of(@collection3, :id), :pre_selected => '211'}
    }
    assert_equal_output(goal, html)
  end

  def test_preselection_with_selected_option
    @collection1 = [ O.new(1, 'A'), O.new(2, 'B')]
    @collection2 = [ O.new(11, 'K', 1), O.new(12, 'L', 1), O.new(21, 'M', 2), O.new(22, 'N', 2) ]

    # Preselect K
    @helper.instance_variable_set(:@select2, Select.new(11))
    options = {}    
    html_code = @helper.collection_select(:select1, :value, @collection1, :id, :name) +
        @helper.related_collection_select(:select2, :value, [:select1, :value], @collection2, :id, :name, :parent_id, options) 

    assert(html_code.ends_with?("$('select1_value').select('1'); $('select2_value').select('11');\n//]]>\n</script>"))

    # Override preselection of K by using options[:select] = 22 and preselect N instead
    options = {:selected => 22}    
    html_code = @helper.collection_select(:select1, :value, @collection1, :id, :name) +
        @helper.related_collection_select(:select2, :value, [:select1, :value], @collection2, :id, :name, :parent_id, options) 

    assert(html_code.ends_with?("$('select1_value').select('2'); $('select2_value').select('22');\n//]]>\n</script>"))
  end

  def test_valid_output_for_options_containing_quotes
    double = O.new(11, 'This string is "double-quoted".', 1)
    single = O.new(21, "This string is 'single-quoted'.", 2)

    @collection1 = [ O.new(1, 'A'), O.new(2, 'B')]
    @collection2 = [ double, single]

    html = @helper.collection_select(:select1, :value, @collection1, :id, :name) +
        @helper.related_collection_select(:select2, :value, [:select1, :value], @collection2, :id, :name, :parent_id)
    goal = {
      :select1_value => {:options => ids_of(@collection1, :id)},
      :select2_value => {:parent => :select1_value, :options => ids_of(@collection2, :id)}
    }
    assert_equal_output(goal, html)
    assert_option(html, double.name) 
    assert_option(html, single.name) 
  end

  def test_multiple_with_preselection
    @collection1 = [ O.new(1, 'A'), O.new(2, 'B')]
    @collection2 = [ O.new(11, 'K', 1), O.new(12, 'L', 1), O.new(21, 'M', 2), O.new(22, 'N', 2) ]
    @collection3 = [ O.new(13, 'O', 1), O.new(14, 'P', 1), O.new(23, 'Q', 2), O.new(24, 'R', 2) ]
    @collection4 = [ O.new(111, 'U', 11), O.new(112, 'V', 11), O.new(121, 'W', 12), O.new(211, 'X', 21), O.new(212, 'Y', 21) ]

    html = @helper.collection_select(:select1, :value, @collection1, :id, :name) +
        @helper.related_collection_select(:select2, :value, [:select1, :value], @collection2, :id, :name, :parent_id) +
          @helper.related_collection_select(:select3, :value, [:select1, :value], @collection3, :id, :name, :parent_id, :selected => 24) +
            @helper.related_collection_select(:select4, :value, [:select2, :value], @collection4, :id, :name, :parent_id)

    goal = {
      :select1_value => {:options => ids_of(@collection1, :id), :pre_selected => "2"},
      :select2_value => {:parent => :select1_value, :options => ids_of(@collection2, :id)},
      :select3_value => {:parent => :select1_value, :options => ids_of(@collection3, :id), :pre_selected => "24"},
      :select4_value => {:parent => :select2_value, :options => ids_of(@collection4, :id)}
    }
    assert_equal_output(goal, html)
    
    assertion = File.open(File.dirname(__FILE__) + "/test_multiple_with_preselection.output", "rb").read
    assertion.gsub!(%r{[\r]}, '')
    html.gsub!(%r{[\r]}, '')
    assert_equal(assertion, html)
  end

  private
    def assert_equal_output(goal, html)
      content = {}
      html.scan(%r{<select.+?id="(.*?)"[^>]*>(.*?)<\/select[^>]*>}im) do |s|
        content[s[0].to_sym] ||= {}
        unless s[1].blank?
          content[s[0].to_sym][:options] ||= []
          s[1].scan(%r{<option.+?value="(.*?)"[^>]*>(.*?)<\/option[^>]*>}im) do |o|
            content[s[0].to_sym][:options] << o[0].to_s
          end
          content[s[0].to_sym][:options] = content[s[0].to_sym][:options].flatten.sort
        end
      end

      html.scan(%r{\$\('(\w+)'\)\.select_parent = \$\('(\w+)'\);}i) do |s|
        content[s[0].to_sym] ||= {}
        unless s[1].blank?
          content[s[0].to_sym][:parent] = s[1].to_sym
          content[s[0].to_sym][:options] ||= []
          html.scan(%r{\$\('#{s[0]}'\)\.relation_hash = \{(.+?)\}}im) do |js_options|
            js_options[0].scan(%r{new Option.+?'(\w+)'\)}i) do |o|
            content[s[0].to_sym][:options] << o[0].to_s
            end
          end
          content[s[0].to_sym][:options] = content[s[0].to_sym][:options].flatten.sort
        end        
      end

      html.scan(%r{\$\('(\w+)'\)\.select\('(\w+)'\);}i) do |s|
        content[s[0].to_sym] ||= {}
        unless s[1].blank?
          content[s[0].to_sym][:pre_selected] = s[1]
        end
      end
            
      assert_equal(goal, content)
    end
    
    def assert_option(html, option)
      options = []
      html.scan(%r{new Option\('(.+?)',.+?\)}i) do |o|
        options << o
      end
      options.flatten!
      assert(options.include?(@helper.escape_javascript(option)))
    end

    def ids_of(collection, id_method)
      collection.collect do |item|
        item.send(id_method).to_s
      end
    end
end
