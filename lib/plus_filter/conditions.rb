# PlusFilter::Conditions is a wrapper for generating ActiveRecord find/cound conditions using 
# the standard sanitize_sql interface
#
# Exaple usage:
#   conditions = PlusFilter::Conditions.new
#   conditions << ['username LIKE ?', '%admin%']
#   conditions << ['active = ?', true]

#   PlusFilter::Conditions.new do |c|
#     c << ['username LIKE ?', '%admin%']
#     c << ['active = ?', true]
#   end
#
#   User.find(:first, :conditions => conditions.to_a)
#   # => SELECT * FROM users WHERE username LIKE '%admin%' AND active = 1
module PlusFilter
  class Conditions

    def initialize(conditions = nil) #:nodoc:
      @expression = []
      @arguments = []
      self << conditions
      yield self if block_given?
    end
  
    # Append a new condition. Conditions must be passed as an sql_sanitize compatible Array, examples:
    #    ['role_id = ?', 33]
    #    ['role_id < ? OR role_id > ?', 2, 100]
    #    ['role_id BETWEEN ? AND ?', 1, 10]
    #    ['role_id IN (?)', [1,2,3,4,5]]
    def <<(condition)
      return if condition.blank?
  
      code = condition.shift
      unless code.blank?
        @expression << code
        @arguments += condition
      end    
    end
    
    # Returns true if no conditions were appended, else false
    def blank?
      @expression.blank?
    end
  
    # Returns the complete unsanitized expression, example:
    #   conditions = FilterConditions.new
    #   conditions << ['username LIKE ?', '%admin%']
    #   conditions << ['active = ?', true]
    #   conditions.expression
    #   # => SELECT * FROM users WHERE username LIKE ? AND active = ?
    def expression
      @expression.map{|chunk| "( #{chunk} )"}.join(' AND ')
    end
  
    # Returns the unsanitized expression arguments, example:
    #   conditions = FilterConditions.new
    #   conditions << ['username LIKE ?', '%admin%']
    #   conditions << ['active = ?', true]
    #   conditions.arguments
    #   # => ['%admin%', true]
    def arguments
      @arguments
    end
  
    # Returns a sql_sanitize compatible array if conditions were appended, else nil
    def to_a
      if self.blank?
        nil
      else
        [expression, *arguments]
      end
    end
  
  end
end
