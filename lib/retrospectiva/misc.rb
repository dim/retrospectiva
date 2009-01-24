module Retrospectiva::Misc
  extend self

  def nullify_orphaned_associations(model, association_name)
    association = model.reflect_on_association(association_name.to_sym)
    source = model.quoted_table_name        
    target = association.quoted_table_name
    primary_key = model.connection.quote_column_name model.primary_key
    foreign_key = association.klass.connection.quote_column_name association.association_foreign_key
    
    sql = "SELECT DISTINCT(#{source}.#{primary_key}) " +        
          "FROM #{source} " +
          "LEFT JOIN #{target} ON #{target}.#{primary_key} = #{source}.#{foreign_key} " +
          "WHERE #{target}.#{primary_key} IS NULL AND #{source}.#{foreign_key} IS NOT NULL"
    
    model.find_by_sql(sql).map(&:id).map(&:to_i).in_groups_of(25).map do |ids|
      model.update_all ["#{foreign_key} = NULL"], ["#{primary_key} IN (?)", ids.compact]
    end.flatten.sum
  end
      
end