class VacationsController < ApplicationController
  before_action :require_login
  before_action :require_manager_login, except: %i(view requests update cancel)

  before_action :set_vacation, only: %i(destroy update cancel)
  before_action :set_employee
  before_action :set_fiscal_year_and_vacations, only: %i(view index)
  before_action :check_edit_permissions, only: %i(index update create destroy)
  before_action :check_view_permissions, only: %i(view requests cancel)

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
    respond_to do |format|
      if @vacation.destroy
        send_confirmation_email unless params['no_mail'] == 'true'
        format.html{redirect_to :back, flash: {success: "Time off successfully deleted."}}
      else
        format.html{redirect_to :back, flash: {error: @vacation.errors.full_messages, created: @vacation.id}}
      end
    end
  end

  def cancel
    unless @vacation.employee == current_user
      redirect_to :back, flash: {error: "You cannot cancel vacations for this employee."}
      return
    end
    
    unless @vacation.status == "Pending"
      redirect_to :back, flash: {error: "Time off is accepted.  You cannot modify the vacation from here.  Please speak with your manager."}
      return
    end
    
    destroy
  end

  def requests
    if current_user.manager.blank?
      redirect_to :back, flash: {error: "You don't have a manager, so you cannot request time off."}
      return
    end

    @vacation = Vacation.new(vacation_params.merge({employee_id: current_user.id,manager_id: current_user.manager.id, status: "Pending"}))
    respond_to do |format|
      if @vacation.save
        VacationRequestMailer.request_email(current_user, current_user.manager, @vacation, params[:memo], params["cc"] == "1" ? current_user.email : nil).deliver
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

    if @employee.vacations.where(vacation_type: "Vacation", status: [nil, ""]).inject(0.0) {|sum, vacation| sum += vacation.pdo_taken(fiscal_year_of_start_date) } > @employee.max_vacation_days(Date.new(fiscal_year_of_start_date))
      warnings << "Time off saved, but this is borrowing days from fiscal year #{fiscal_year_of_start_date+1}."
    end
    if fiscal_year_of_start_date != fiscal_year_of_end_date and @employee.vacations.where(vacation_type: "Vacation", status: [nil, ""]).inject(0.0) {|sum, vacation| sum += vacation.pdo_taken(fiscal_year_of_end_date) } > @employee.max_vacation_days(Date.new(fiscal_year_of_end_date))
      warnings << "Time off saved, but this is borrowing days from fiscal year #{fiscal_year_of_end_date+1}."
    end
    warnings
  end

  def send_confirmation_email
    if params["confirm"].present?
      VacationRequestMailer.confirm_email(current_user, @employee, @vacation, params["confirm"]=="true").deliver
    elsif @employee.manager.present? && @vacation.pending?
      VacationRequestMailer.cancel_email(current_user, @employee.manager, @vacation).deliver
    end
  end

  def set_fiscal_year_and_vacations
    @fyear = params['fy'].blank? ? Vacation.calculate_fiscal_year : params['fy'].to_i
    starting_year = @employee.start_date.blank? ? Date.current.year : @employee.start_date.fiscal_new_year.year
    unless @employee.vacations.count == 0
      first_logged_vacation_year = @employee.vacations.order(start_date: :asc).first.start_date.year
      starting_year = first_logged_vacation_year < starting_year ? first_logged_vacation_year : starting_year
    end
    @fy_options = (starting_year..Date.current.year+1).collect {|date| ["Fiscal Year #{date}",date]}.reverse
    @fy_vacations = @employee.vacations
      .where("start_date >= ? and start_date < ? or end_date >= ? and end_date < ?",Date.new(@fyear).previous_fiscal_new_year,Date.new(@fyear).fiscal_new_year,Date.new(@fyear).previous_fiscal_new_year,Date.new(@fyear).fiscal_new_year)
      .order("#{params[:sort].blank? ? :start_date : params[:sort]} #{params[:rev]!='true' ? 'ASC' : 'DESC'}")
    @any_with_pending_status = @fy_vacations.where(status: "Pending").count > 0
  end

  def check_edit_permissions
    unless current_user.can_edit? @employee
      redirect_to :root, flash: {error: "You have insufficient privileges to edit time off for that employee."}
    end
  end

  def check_view_permissions
    unless current_user.can_view? @employee
      redirect_to :root, flash: {error: "You have insufficient privileges to view time off for that employee."}
    end
  end

  def set_vacation
    begin
      @vacation = Vacation.find(params[:id])
    rescue
      respond_to do |format|
        format.html {redirect_to :back, flash: {error: 'Time off not found in BlueSource.'}}
      end
    end
  end

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  def vacation_params
     initial_params = if params[:id].present?
                         params[params[:id]]
                       elsif params['new'].blank?
                         params
                       else
                         params['new']
                       end

     all_params = initial_params.require(:vacation).permit(:date_requested,:start_date,:end_date,:vacation_type,:business_days,:employee_id,:half_day,:reason,:status)
     all_params[:manager_id]=current_user.id
     all_params[:employee_id]=params[:employee_id]
     all_params[:status]=''
     all_params[:half_day]=false if all_params[:half_day].blank?
     return all_params
  end
end
