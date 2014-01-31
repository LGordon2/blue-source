class VacationsController < ApplicationController
  before_action :require_manager_login, except: [:view, :requests, :destroy]
  
  before_action :set_vacation, only: [:destroy, :update]
  before_action :set_employee
  before_action :set_fiscal_year_and_vacations, only: [:view, :index]
  before_action :validate_user_is_above_employee, except: [:view, :requests, :destroy]
  before_action :validate_user_is_employee_or_above, only: [:view]
  
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
        warning_msg = check_vacation_days
        unless warning_msg.blank?
          format.html {redirect_to employee_vacations_path(@employee), flash: {warning: warning_msg, created: @vacation.id}}
        else
          format.html {redirect_to employee_vacations_path(@employee, "fy" => @vacation.start_date.current_fiscal_year), flash: {success: "Time off successfully saved.", created: @vacation.id}}
        end
      else
        format.html{redirect_to employee_vacations_path(@employee), flash: {error: @vacation.errors.full_messages}}
      end
    end
  end
  
  def update
    respond_to do |format|
      if @vacation.update(vacation_params)
        send_confirmation_email
        warning_msg = check_vacation_days
        unless warning_msg.blank?
          format.html {redirect_to employee_vacations_path(@employee, "fy" => @vacation.start_date.current_fiscal_year), flash: {warning: warning_msg, created: @vacation.id}}
        else
          format.html {redirect_to employee_vacations_path(@employee, "fy" => @vacation.start_date.current_fiscal_year), flash: {success: "Time off successfully updated.", created: @vacation.id}}
        end
      else
        format.html {redirect_to :back, flash: {error: @vacation.errors.full_messages, created: @vacation.id}}
      end
    end
  end
  
  def destroy
    if (@vacation.status.blank? and (!current_user.above? @vacation.employee and !current_user.admin?))
      redirect_to :back, flash: {error: "Vacation is accepted.  You cannot modify the vacation from here.  Please speak with your manager."}
      return
    end
    respond_to do |format|
      if @vacation.destroy
        send_confirmation_email
        format.html{redirect_to :back, flash: {success: "Vacation successfully deleted."}}
      else
        format.html{redirect_to :back, flash: {error: @vacation.errors.full_messages, created: @vacation.id}}
      end
    end
  end
  
  def requests
    if current_user.manager.blank?
      redirect_to :back, flash: {error: "You don't have a manager, so you cannot request time off."}
      return
    end
    
    @vacation = Vacation.new(vacation_params.merge({employee_id: current_user.id,manager_id: current_user.manager.id, status: "Pending"}))
    respond_to do |format|
      if @vacation.save
        VacationRequestMailer.request_email(current_user, current_user.manager, vacation_params, params[:memo], params["cc"] == "1" ? current_user.email : nil).deliver
        format.html {redirect_to view_employee_vacations_path(current_user, "fy" => @vacation.start_date.current_fiscal_year), flash: {success: "Time off successfully saved.", created: @vacation.id}}
      else
        format.html{redirect_to :back, flash: {error: @vacation.errors.full_messages}}
      end
    end
  end
  
  private
  
  def check_vacation_days
    return nil unless @vacation.vacation_type == "Vacation"
    fiscal_year_of_start_date = @vacation.start_date.current_fiscal_year
    fiscal_year_of_end_date = @vacation.end_date.current_fiscal_year
    warnings = []
    
    if @employee.vacations.where(vacation_type: "Vacation").inject(0.0) {|sum, vacation| sum += vacation.pdo_taken(fiscal_year_of_start_date) } > @employee.max_vacation_days(Date.new(fiscal_year_of_start_date))
      warnings << "Vacation saved, but this is borrowing days from fiscal year #{fiscal_year_of_start_date+1}."
    end 
    if fiscal_year_of_start_date != fiscal_year_of_end_date and @employee.vacations.where(vacation_type: "Vacation").inject(0.0) {|sum, vacation| sum += vacation.pdo_taken(fiscal_year_of_end_date) } > @employee.max_vacation_days(Date.new(fiscal_year_of_end_date))
      warnings << "Vacation saved, but this is borrowing days from fiscal year #{fiscal_year_of_end_date+1}."
    end
    warnings
  end
  
  def send_confirmation_email
     VacationRequestMailer.confirm_email(current_user, @employee, @vacation, params["confirm"]=="true").deliver unless params["confirm"].blank?
  end
  
  def set_fiscal_year_and_vacations
    @fyear = params['fy'].blank? ? Vacation.calculate_fiscal_year : params['fy'].to_i
    starting_year = @employee.start_date.blank? ? Date.current.year : @employee.start_date.fiscal_new_year.year
    @fy_options = (starting_year..Date.current.year+1).collect {|date| ["Fiscal Year #{date}",date]}.reverse
    @fy_vacations = @employee.vacations
      .where("start_date >= ? and start_date < ? or end_date >= ? and end_date < ?",Date.new(@fyear).previous_fiscal_new_year,Date.new(@fyear).fiscal_new_year,Date.new(@fyear).previous_fiscal_new_year,Date.new(@fyear).fiscal_new_year)
      .order("#{params[:sort].blank? ? :date_requested : params[:sort]} #{params[:rev]!='true' ? 'ASC' : 'DESC'}")
    @any_with_pending_status = @fy_vacations.where(status: "Pending").count > 0
  end
  
  def validate_user_is_above_employee
    unless current_user.admin? or current_user.above? @employee
      redirect_to :root, flash: {error: "You have insufficient privileges to edit vacations for that employee."}
    end
  end  
  
  def validate_user_is_employee_or_above
    unless current_user.admin? or current_user.above? @employee or current_user == @employee
      redirect_to view_employee_vacations_path(current_user), flash: {error: "You have insufficient privileges to view vacations for that employee."}
    end
  end
    
  def set_vacation
    begin
      @vacation = Vacation.find(params[:id])
    rescue
      respond_to do |format|
        format.html {redirect_to :back, flash: {error: "Vacation not found in BlueSource."}}
      end
    end
  end
  
  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
  
  def vacation_params
     all_params = params.require(:vacation).permit(:date_requested,:start_date,:end_date,:vacation_type,:business_days,:employee_id,:half_day,:reason,:status)
     all_params[:manager_id]=current_user.id
     return all_params
  end 
end
