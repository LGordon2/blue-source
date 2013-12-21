include VacationHelper::PTO

@anniversary_date = Date.new(2013,11,25)
@last_fiscal_new_year = Date.new(calculate_fiscal_year-1,5,1)
def max_vacation_days(date)
  return a = if date < @anniversary_date then 10 else 13 end
end

def pdo_taken_in_range(start_date, end_date, type)
  pdo_days = 0.0
  self.vacations.where(vacation_type: type).where("start_date >= ? and end_date <= ?",start_date.to_s,end_date.to_s).each do |vacation|
    pdo_days += vacation.business_days
  end
end

def days_taken_this_fiscal_year(date=Date.current)
  return days_taken(Date.new(calculate_fiscal_year-1,5,1),Date.new(calculate_fiscal_year,5,1))
end

def validate_pto(start_date, end_date)
  date_range = (start_date..end_date)
  business_days_taken_range = calc_business_days_for_range(start_date,end_date)
  if !@anniversary_date.in?(date_range)
    return business_days_taken_range + days_taken_this_fiscal_year <= max_vacation_days(start_date)
  end
  
  if end_date < @anniversary_date
    return days_taken(@last_fiscal_new_year,@anniversary_date-1) + business_days_taken_range <= max_vacation_days(end_date)
  else
    return days_taken(@last_fiscal_new_year,@anniversary_date-1) + calc_business_days_for_range(start_date,@anniversary_date-1) <= max_vacation_days(start_date) &&
    days_taken_this_fiscal_year + calc_business_days_for_range(@anniversary_date,end_date) <= max_vacation_days(@anniversary_date)
  end  
end

#Test Cases...
puts "Test Cases"
puts validate_pto(Date.new(2014,1,2),Date.new(2014,1,16)) ? "Passed" : "Failed"
puts validate_pto(Date.new(2013,11,4),Date.new(2013,11,15)) ? "Passed" : "Failed"
puts validate_pto(Date.new(2013,11,4),Date.new(2013,11,18)) ? "Failed" : "Passed"
puts validate_pto(Date.new(2013,11,25),Date.new(2013,11,26)) ? "Passed" : "Failed"
