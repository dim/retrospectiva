#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class TimeInterval      
  attr_reader :in_seconds

  UNITS = %w{year month week day hour minute}          
      
  def initialize(interval_in_seconds)
    @in_seconds = interval_in_seconds
  end

  def self.match(seconds, count_range, options = {})
    (options[:units] || UNITS).reverse.each do |u|      
      max_seconds_per_unit = in_seconds(count_range.last, u)
      next if max_seconds_per_unit < seconds        

      count_range.each do |c|                  
        seconds_per_unit = in_seconds(c, u)
        next if seconds_per_unit < seconds

        return [c, ActiveSupport::Inflector.pluralize(u)]                
      end
    end
    [count_range.to_a.last, 'years']    
  end

  def self.in_seconds(count, unit)
    eval("#{count}." + ActiveSupport::Inflector.pluralize(unit))
  end

  def count
    to_a[0]
  end
        
  def unit
    to_a[1]
  end
    
  def units
    ActiveSupport::Inflector.pluralize(unit)
  end

  def to_a
    UNITS.each do |u|
      seconds_per_unit = eval("1." + ActiveSupport::Inflector.pluralize(u))
      return [(in_seconds.to_f / seconds_per_unit), u] if in_seconds.abs > seconds_per_unit
    end
    return [1, 'minute']
  end          
  
end

module TimeIntervalHelper
  # Selection of a time interval
  def time_interval_select(name, method, options = {}, select_options = {})
    obj = eval("@#{name}")
    skip = [options[:skip]].flatten.compact.map(&:singularize)
    if obj && obj.respond_to?(method) && seconds = obj.send(method)
      options[:range] ||= 1..60
      options[:count], options[:units] = TimeInterval.match(seconds, options[:range], :units => (TimeInterval::UNITS - skip))
    end
    time_interval_select_tag "#{name}[#{method}]", options, select_options
  end


  def time_interval_select_tag(name, options = {}, select_options = {})
    options.symbolize_keys!

    options[:range] ||= 1..60
    options[:units] ||= select_options[:include_blank] ? nil : 'days'
    options[:count] ||= select_options[:include_blank] ? nil : options[:range].first

    skip = options.delete(:skip) || []
    unit_fields = []
    unit_fields << [ _('Minutes'), 'minutes' ] unless skip.include?('minutes')
    unit_fields << [ _('Hours'), 'hours' ]     unless skip.include?('hours')
    unit_fields << [ _('Days'), 'days' ]       unless skip.include?('days')
    unit_fields << [ _('Weeks'), 'weeks' ]     unless skip.include?('weeks')
    unit_fields << [ _('Months'), 'months' ]   unless skip.include?('months')

    count_options = options_for_select(options[:range], options[:count])
    count_options = "<option value=\"\"></option>\n" + count_options if select_options[:include_blank]

    units_options = options_for_select(unit_fields, options[:units])
    units_options = "<option value=\"\"></option>\n" + units_options if select_options[:include_blank]

    tag_id = select_options[:id] || name.gsub(/[\[\]]/, '_').gsub(/_+$/, '')
    
    select_tag("#{name}[count]", count_options, :id => tag_id) + ' ' +
      select_tag("#{name}[units]", units_options, :id => "#{tag_id}_units")
  end 

end
ActionView::Base.send(:include, TimeIntervalHelper)
