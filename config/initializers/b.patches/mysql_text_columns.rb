ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do

  def type_to_sql_with_text_limits(type, limit = nil, precision = nil, scale = nil)
    if type.to_s == 'text' and limit
      case limit
      when 0...256                          then 'tinytext'
      when 256...64.kilobytes               then 'text'
      when 64.kilobytes...16.megabytes      then 'mediumtext'
      else                                       'longtext'
      end
    else
      type_to_sql_without_text_limits(type, limit, precision, scale)
    end
  end
  alias_method_chain :type_to_sql, :text_limits

end if ActiveRecord::ConnectionAdapters.const_defined?(:MysqlAdapter)
