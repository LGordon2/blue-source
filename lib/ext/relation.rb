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
  
  def report_nil(column)
    raise ArgumentError, "Column is invalid." unless column.in? self.column_names  
    self.where("#{column.to_s}" => nil)
  end
  
  private
  
  def report_relation(column, data, operator)
    raise ArgumentError, "Column is invalid." unless column.in? self.column_names  
    self.where("#{column.to_s} #{operator} ?",data)
  end
end
