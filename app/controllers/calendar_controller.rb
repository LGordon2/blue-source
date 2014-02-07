class CalendarController < ApplicationController
  before_action :require_login
  
  helper_method :get_orasi_holiday
  
  def index
    @max_entries_per_day = 4
    @all_months = (1..12).collect {|month_no| [Date.new(2014,month_no,1).strftime("%B"), month_no]}
    unless params[:year].blank? or params[:month].blank?
      @starting_date = Date.new(params[:year].to_i,params[:month].to_i,1)
    else
      @starting_date = Date.current.change(day: 1)
    end
    @filter_types = ['all']
    @selected_filter_type = "all"
    
    unless current_user.subordinates.blank?
      @filter_types << 'direct'
      @selected_filter_type = 'direct' 
    end
    
    unless current_user.department.blank?
      @filter_types << 'department'
      @selected_filter_type = 'department'
    end
    
    unless params[:filter].blank?
      @selected_filter_type = params[:filter]
    end
    
    case @selected_filter_type
    when 'all'
      @pdo_times = Vacation.all
    when 'department'
      @pdo_times = Vacation.where(employee_id: current_user.department.employees.pluck(:id))
    when 'direct'
      @pdo_times = Vacation.where(employee_id: current_user.subordinates.pluck(:id))
    end
    
    unless @pdo_times.blank?
      @selectable_years = (@pdo_times.order(start_date: :asc).first.start_date.year..@pdo_times.order(end_date: :desc).first.end_date.year)
    else
      @selectable_years = (Date.current.year-2..Date.current.year+2)
    end
    
    @pdo_times = @pdo_times.where.not(status: "Pending").where("(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)",@starting_date.beginning_of_month,@starting_date.end_of_month,@starting_date.beginning_of_month,@starting_date.end_of_month)
    
  end
  
  private
  
  def get_orasi_holiday(day)
    case
    when (day.month == 5 and day.day == 1)
      "Fiscal New Year"
    when day.new_years_day?
      "New Year's Day"
    when day.memorial_day?
      "Memorial Day"
    when day.independence_day?
      "Independence Day"
    when day.labor_day?
      "Labor Day"
    when day.thanksgiving?
      "Thanksgiving Day"
    when day.christmas_eve?
      "Christmas Eve"
    when day.christmas?
      "Christmas Day"
    end
  end
end
