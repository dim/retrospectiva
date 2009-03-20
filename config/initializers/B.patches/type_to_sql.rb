ActiveRecord::ConnectionAdapters::SchemaStatements.module_eval do

  def type_to_sql_with_raw_type(type, limit = nil, precision = nil, scale = nil) #:nodoc:
    if [:text, :datetime].include?(type)
      type_to_sql_without_raw_type(type)
    else
      type_to_sql_without_raw_type(type, limit, precision, scale)
    end
  end
  alias_method_chain :type_to_sql, :raw_type

end