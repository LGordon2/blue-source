include VacationHelper
def calculate_fiscal_year(date = Date.current)
  date >= Date.new(date.year, 05, 01) ? date.year+1 : date.year
end

def fiscal_new_year_date(date = Date.current)
  Date.new(calculate_fiscal_year(date),05,01)
end

def calc_business_days_for_range(start_date, end_date)
  total = 0
  (start_date..end_date).each do |date|
    total += 1 unless date.saturday? or date.sunday? or 
    date.thanksgiving? or date.labor_day? or date.memorial_day? or
    date.christmas? or date.christmas_eve? or date.independence_day? or
    date.black_friday?
  end
  return total
end

def vacation_days_taken(year = Date.current.year)
  return 0 
end

def max_vacation_days(year = Date.current.year)
  return 10
end

def validate_days_taken(start_date,end_date)
  date_range = (start_date..end_date)
  fiscal_new_year = fiscal_new_year_date(start_date)
  if fiscal_new_year.in?(date_range) and start_date != fiscal_new_year
    return validate_days_taken(start_date,fiscal_new_year-1) && validate_days_taken(fiscal_new_year,end_date)
  end
  
  business_days_taken_in_range = calc_business_days_for_range(start_date, end_date)
  business_days_already_taken = vacation_days_taken
  
  return business_days_taken_in_range + business_days_already_taken <= max_vacation_days
end

start_date = Date.new(2014,4,18)
end_date = Date.new(2014,5,2)

#puts fiscal_new_year_date(start_date)+1
puts validate_days_taken(start_date,end_date)
