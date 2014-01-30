class AbsentController < ApplicationController
  before_action :require_manager_login
  
  def index
    @all_absent_today = Vacation.where.not(status: "Pending").select do |vacation|
      Date.current.in? (vacation.start_date..vacation.end_date)
    end
    
    @all_absent_this_week = Vacation.select("employee_id").where.not(status: "Pending").group("employee_id").collect do |employee_row|
      employee = Employee.find(employee_row.employee_id)
      days = employee.vacations.order(start_date: :asc).collect do |vacation|
        vacation_days = (Date.current.monday..Date.current.monday + 4.days).select do |work_week_day|
          work_week_day.in? (vacation.start_date..vacation.end_date)
        end
        {vacation_type: vacation.vacation_type, vacation_days: vacation_days} unless vacation_days.blank?
      end
      days = days.select {|d| !d.blank? }
      {name: employee.display_name, days_taken: days}
    end
  end
  
end
