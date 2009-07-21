class TicketFilter::Item < Array
  attr_reader :name, :selected_ids

  delegate :include?, :to => :selected_ids 
  
  def initialize(name, records, selected_ids, options = {})
    super(records)
    @name = name.to_s
    @options = options.dup
    @selected_ids = select_valid(*selected_ids)
  end
  
  def label
    @options[:label] || @name.titleize
  end
  
  def selected?
    selected_ids.any?
  end

  def conditions
    return nil unless selected?

    case @options[:conditions]
    when Proc
      value = PlusFilter::Conditions.new      
      @options[:conditions].call(self, value)
      value.to_a
    when String
      [@options[:conditions], selected_ids]
    else
      nil
    end
  end

  def joins
    return nil unless selected?
    
    case @options[:joins]
    when Proc
      @options[:joins].call(self)
    when String
      ActiveRecord::Base.send :sanitize_sql_array, [@options[:joins], selected_ids]
    else
      nil
    end
  end

  def select(*ids_to_select)
    @selected_ids = select_valid(@selected_ids + ids_to_select)
  end
  
  protected

    def select_valid(*ids_to_select)
      [ids_to_select].flatten.map(&:to_i) & valid_ids
    end 
  
    def valid_ids
      map(&:id)
    end
  
end
