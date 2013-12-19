include VacationHelper::PTO

start_date = Date.new(2014,4,17)
end_date = Date.new(2014,5,21)
puts validate_days_taken(start_date,end_date)