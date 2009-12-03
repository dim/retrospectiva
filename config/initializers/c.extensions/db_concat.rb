ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
  def concat(*quoted_values)
    quoted_values.map(&:to_s).join(' || ')
  end
end

ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
  def concat(*quoted_values)
    "CONCAT(#{quoted_values.map(&:to_s).join(', ')})"
  end
end if ActiveRecord::ConnectionAdapters.const_defined?(:MysqlAdapter)
