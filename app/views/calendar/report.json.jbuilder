json.array! (@vacations).each do |vacation|
  end_date = [Date.parse(params["filter"]["end_date"]),vacation.end_date].min
  start_date = [Date.parse(params["filter"]["start_date"]),vacation.start_date].max
  
  json.name vacation.employee.display_name
  json.start_date start_date
  json.end_date end_date
  json.department vacation.employee.department.name unless vacation.employee.department.blank?
  json.vacation_type vacation.vacation_type
  json.business_days calc_business_days_for_range(start_date, end_date) - ((vacation.half_day and end_date == vacation.end_date) ? 0.5 : 0)
end