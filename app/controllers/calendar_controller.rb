class CalendarController < ApplicationController
  include VacationHelper

  before_action :require_login
  helper_method :get_orasi_holiday, :change_month

  def report
    errors = []
    if filter_params[:start_date].blank?
      errors << "Start date is required for reporting"
    end
    if filter_params[:end_date].blank?
      errors << "End date is required for reporting"
    end
    unless errors.blank?
      redirect_to :root, flash: {error: errors}
    end

    @vacation_types = filter_params.collect {|type, value| type.to_s.gsub("_", " ").titleize if (value.is_a?(String) and value.to_i == 1)}.compact
    @vacations = Vacation
      .where(vacation_type: @vacation_types)
      .vacations_in_range(filter_params["start_date"],filter_params["end_date"])

    unless filter_params["pending"].blank?
      filter_params["pending"].each do |type, value|
        @vacations = @vacations.where.not("vacation_type == ? AND status == ?", type.to_s.gsub("_", " ").titleize, "Pending") if value.to_i == 1
      end
    end

    unless filter_params['department'].blank?
      @vacations = @vacations.where(employee_id: Department.find(filter_params['department']).employees.pluck(:id))
    end

    unless params[:sort].blank?
      case params[:sort].to_sym
      when :name
        @vacations = @vacations.joins(:employee).order("employees.first_name")
      when :department
        @vacations = @vacations.joins(:employee).joins("LEFT JOIN departments on employees.department_id == departments.id").order("departments.name")
      else
        @vacations = @vacations.order(params[:sort])
      end
    end

    @vacations = @vacations.reverse_order if params["rev"] == "true"

    respond_to do |format|
      format.html do
        pageNumber = params["pgn"].to_i
        pageNumber = 1 if pageNumber <= 0
        @activePage = pageNumber - 1
        resourcesPerPage = if current_user.preferences.blank? or current_user.preferences["resourcesPerPage"].blank?
          15
        else
          current_user.preferences["resourcesPerPage"].to_i
        end

        @page_count = @vacations.count / resourcesPerPage
        @max_pagination_pages = 10
        @vacations = @vacations.limit(resourcesPerPage).offset(resourcesPerPage*(pageNumber-1))
      end
      format.json
      format.xls
      format.csv
    end
  end

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
      @pdo_times = Vacation.where(employee_id: current_user.subordinates.pluck(:id) + [current_user.id])
    end

    unless @pdo_times.blank?
      @selectable_years = (@pdo_times.order(start_date: :asc).first.start_date.year..@pdo_times.order(end_date: :desc).first.end_date.year)
    else
      @selectable_years = (Date.current.year-2..Date.current.year+2)
    end

    @disabled_prev_month = (@starting_date - 1.month).year < @selectable_years.first
    @disabled_next_month = (@starting_date + 1.month).year > @selectable_years.last

    @pdo_times = @pdo_times.vacations_in_range(@starting_date.beginning_of_month, @starting_date.end_of_month)
  end

  def change_month(no_months)
    months_to_add = no_months.months
    if params[:month].blank? or params[:year].blank?
      prev_date = Date.current
    else
      prev_date = Date.new(params[:year].to_i, params[:month].to_i, 1)
    end
    new_date = prev_date + months_to_add
    new_params = params.merge({month: new_date.month, year: new_date.year})
    return new_params
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

  def filter_params
    params.require(:filter).permit(:start_date,:end_date,:department,:sick,:vacation,:floating_holiday,:other, {pending: [:sick, :vacation, :floating_holiday]})
  end
end
