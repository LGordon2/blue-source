json.array! (@report_vacations).each do |vacation|
  json.name vacation.employee_name
  json.start_date vacation.start_date
  json.end_date vacation.end_date
  json.department vacation.employee_dept_name
  json.vacation_type vacation.vacation_type
  json.business_days vacation.business_days

  if @include_reasons
    json.reason vacation.reason
  end
end