class TicketFilter::Collection < Array
  attr_reader :params, :project, :to_params

  def initialize(params, project)
    super()
    @params = params.stringify_keys
    @project = project
    push_global_items!
    push_custom_items!
    push_other_items!
    create_output!
    pre_select!
  end

  
  def to_params
    @to_params ||= inject({}) do |result, item|
      result[item.name] = item.selected_ids.sort.freeze if item.selected?
      result
    end.freeze
  end
  alias_method :create_output!, :to_params 
  
  def including(name, id)
    name, id = name.to_s, id.to_i
    real_params.tap do |result|      
      result[name] ||= []
      result[name] << id      
      if name == 'status'
        result.delete('state')      
      end      
    end
  end

  def excluding(name, id)
    name, id = name.to_s, id.to_i
    real_params.tap do |result|
      
      if result[name] == [id]
        result.delete(name)
      elsif result.key?(name)
        result[name].delete(id)
      end
      
      if name == 'status'
        result.delete('state')        
      elsif name == 'state' and result['status']
        result['status'].reject! do |status_id|
          status_hash[status_id].nil? || status_hash[status_id].state_id == id 
        end 
      end
      
    end
  end
  
  def conditions
    PlusFilter::Conditions.new.tap do |values|
      each {|i| values << i.conditions if i.selected? }
    end.to_a
  end

  def joins
    values = map(&:joins).compact
    values.any? ? values.join(' ') : nil
  end

  def default?
    to_params.blank? or to_params == { 'state' => [1, 2] }
  end

  def [](*args)
    case args.first
    when Symbol, String
      index[args.first.to_s]
    else                     
      super(*args)
    end
  end  

  def index
    @index ||= index_by(&:name)
  end

  protected
  
    def push_global_items!
      property :state, states, :label => _('State')
      property :status, statuses, :label => _('Status'), :conditions => 'statuses.id IN (?)'
      property :priority, priorities, :label => _('Priority'), :conditions => 'priorities.id IN (?)'
      property :milestone, milestones, :label => _('Milestone'), :conditions => 'milestones.id IN (?)'
    end
  
    def push_custom_items!
      ticket_properties.each do |property_type|
        name = property_type.class_name.underscore
        records = property_type.ticket_properties

        property name, records, 
          :label => property_type.name, 
          :joins => "INNER JOIN ticket_properties_tickets AS ticket_property_#{name} ON ticket_property_#{name}.ticket_property_id IN (?) AND ticket_property_#{name}.ticket_id = tickets.id"
      end
    end

    def push_other_items!
      custom_property(:my_tickets) unless User.current.public?
    end  

    def pre_select!      
      self[:state].select(1, 2) if default? 

      self[:status].each do |status|
        self[:status].select(status.id) if self[:state].include?(status.state_id)
      end if self[:state].selected?      
    end

    def before_add(key, records, options = {})
    end
    
    def after_add(key, records, options = {})
    end

    def real_params
      inject({}) do |result, item|
        result[item.name] = item.selected_ids.sort if item.selected?
        result
      end
    end

  private

    def property(name, records, options = {})
      name = name.to_s
      if records.any? && before_add(name, records, options) != false
        self << TicketFilter::Item.new(name, records, params[name], options)
        after_add(name, records, options)
      end
    end

    def custom_property(symbol)
      instance = "TicketFilter::Custom::#{symbol.to_s.camelize}".constantize.new
      property(instance.name, instance.items, instance.options)
    end
  
    def ticket_properties
      @ticket_properties ||= project.ticket_property_types.find(:all, :include => :ticket_properties)
    end
    
    def states
      @states ||= statuses.map(&:state).uniq.sort_by(&:id)
    end
    
    def statuses
      @statuses ||= Status.find :all, :order => 'rank'
    end
  
    def status_hash
      @status_hash ||= statuses.index_by(&:id)
    end
  
    def priorities
      @priorities ||= Priority.find :all, :order => 'rank'
    end
  
    def milestones
      @milestones ||= project.milestones.in_default_order.find :all
    end  
end
