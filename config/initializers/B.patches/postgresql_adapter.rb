ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do

  def distinct(columns, order_by) #:nodoc:
    return "DISTINCT #{columns}" if order_by.blank?

    # Construct a clean list of column names from the ORDER BY clause, removing
    # any ASC/DESC modifiers    
    order_columns = order_by.split(',').map {|s| s.strip.sub(/ +(DE|A)SC$/i, '') }
    order_columns.delete_if &:blank?
    order_columns = order_columns.zip((0...order_columns.size).to_a).map { |s,i| "#{s} AS alias_#{i}" }

    # Return a DISTINCT ON() clause that's distinct on the columns we want but includes
    # all the required columns for the ORDER BY to work properly.
    sql = "DISTINCT ON (#{columns}) #{columns}, "
    sql << order_columns * ', '
  end

end if ActiveRecord::ConnectionAdapters.const_defined?(:PostgreSQLAdapter)
