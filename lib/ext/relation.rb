class ActiveRecord::Relation
  def report_less_than(column, data)
    report_relation(column, data, "<")
  end
  
  def report_equals(column, data)
    report_relation(column, data, "=")
  end
  
  def report_greater_than(column, data)
    report_relation(column, data, ">")
  end
  
  def report_greater_than_or_equal(column, data)
    report_relation(column, data, ">=")
  end
  
  def report_less_than_or_equal(column, data)
    report_relation(column, data, "<=")
  end
  
  private
  
  def report_relation(column, data, operator)
    raise ArgumentError, "Column is invalid." unless column.in? self.column_names  
    self.where("#{column} #{operator} ?",data)
  end
end
