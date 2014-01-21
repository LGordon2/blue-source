class VacationsController < ApplicationController
  before_action :require_manager_login
  
  before_action :set_vacation, only: [:destroy, :update]
  before_action :set_employee
  before_action :validate_user_is_above_employee
  
  def index
    @fyear = params['fy'].blank? ? Vacation.calculate_fiscal_year : params['fy'].to_i
    @fy_options = (Date.current.year-5..Date.current.year+1).collect {|date| ["FY#{date}",date]}.reverse
    respond_to do |format|
      format.json {render json: @employee.vacations}
      format.html
    end
  end
  
  def create
    @vacation = Vacation.new(vacation_params)
    respond_to do |format|
      if @vacation.save
        format.html {redirect_to :back, flash: {notice: "Time off successfully saved.", created: @vacation.id}}
      else
        format.html{redirect_to :back, flash: {error: @vacation.errors.full_messages}}
      end
    end
  end
  
  def update
    respond_to do |format|
      if @vacation.update(vacation_params)
        format.html {redirect_to :back, flash: {notice: "Time off successfully updated.", created: @vacation.id}}
      else
        format.html {redirect_to :back, flash: {error: @vacation.errors.full_messages}}
      end
    end
  end
  
  def destroy
    respond_to do |format|
      @vacation.destroy
      format.html{redirect_to :back, flash: {notice: "Vacation successfully deleted."}}
    end
  end
  
  def edit
    
  end
  
  private
  
  def validate_user_is_above_employee
    unless current_user.admin? or current_user.above? @employee
      redirect_to :back, flash: {error: "You have insufficient privileges to edit vacations for this employee."}
    end
  end  
    
  def set_vacation
    @vacation = Vacation.find(params[:id])
  end
  
  def set_employee
    @employee = Employee.find(params[:employee_id])#if params[:vacation] and params[:vacation][:employee_id] then Employee.find(params[:vacation][:employee_id]) else @vacation.employee end
  end
  
  def vacation_params
     all_params = params.require(:vacation).permit(:date_requested,:start_date,:end_date,:vacation_type,:business_days,:employee_id,:half_day,:reason)
     all_params[:manager_id]=current_user.id
     return all_params
  end 
end
