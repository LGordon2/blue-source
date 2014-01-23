class VacationsController < ApplicationController
  before_action :require_manager_login, except: [:view]
  
  before_action :set_vacation, only: [:destroy, :update]
  before_action :set_employee
  before_action :set_fiscal_year_and_vacations, only: [:view, :index]
  before_action :validate_user_is_above_employee, except: [:view]
  
  def index
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
        format.html {redirect_to :back, flash: {error: @vacation.errors.full_messages, updated: @vacation.id}}
      end
    end
  end
  
  def destroy
    respond_to do |format|
      @vacation.destroy
      format.html{redirect_to employee_vacations_path(@employee), flash: {notice: "Vacation successfully deleted."}}
    end
  end
  
  def edit
    
  end
  
  private
  
  def set_fiscal_year_and_vacations
    @fyear = params['fy'].blank? ? Vacation.calculate_fiscal_year : params['fy'].to_i
    starting_year = @employee.start_date.blank? ? Date.current.year : @employee.start_date.fiscal_new_year.year
    @fy_options = (starting_year..Date.current.year+1).collect {|date| ["Fiscal Year #{date}",date]}.reverse
    @fy_vacations = @employee.vacations
      .where("start_date >= ? and start_date < ?",Date.new(@fyear).previous_fiscal_new_year,Date.new(@fyear).fiscal_new_year)
      .order("#{params[:sort].blank? ? :date_requested : params[:sort]} #{params[:rev]!='true' ? 'ASC' : 'DESC'}")
  end
  
  def validate_user_is_above_employee
    unless current_user.admin? or current_user.above? @employee
      redirect_to :root, flash: {error: "You have insufficient privileges to edit vacations for this employee."}
    end
  end  
    
  def set_vacation
    @vacation = Vacation.find(params[:id])
  end
  
  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
  
  def vacation_params
     all_params = params.require(:vacation).permit(:date_requested,:start_date,:end_date,:vacation_type,:business_days,:employee_id,:half_day,:reason)
     all_params[:manager_id]=current_user.id
     return all_params
  end 
end
