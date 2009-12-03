ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do

  private
  
    def select_with_force_encoding(sql, name = nil)
      select_without_force_encoding(sql, name).map do |row|
        row.each do |key, value| 
          next unless value.is_a?(String)
          row[key] = value.force_encoding('UTF-8')
        end
        row
      end
    end
    alias_method_chain :select, :force_encoding
    
end if ActiveRecord::ConnectionAdapters.const_defined?(:MysqlAdapter) and RUBY_VERSION.to_f >= 1.9
