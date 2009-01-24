class TicketFilter::Item < Array
  attr_reader :name, :selected_ids
  
  def initialize(name, records, selected_ids, options = {})
    super(records)
    @name = name.to_s
    @options = options
    @selected_ids = select_valid(*selected_ids)
  end
  
  def label
    @options[:label] || @name.titleize
  end
  
  def selected?
    selected_ids.any?
  end

  def conditions
    case @options[:conditions]
    when Proc
      @options[:conditions].call(self, PlusFilter::Conditions.new).to_a
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
      ActiveRecord::Base.send :sanitize_sql, [@options[:joins], selected_ids]
    else
      nil
    end
  end

  def include?(id)   
    selected_ids.include?(id)
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
