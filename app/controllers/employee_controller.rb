class EmployeeController < ApplicationController
  before_action :require_manager_login, except: :view_vacation
  before_action :set_user, only: [:index, :edit, :vacation, :update, :view_vacation]
  
  #Only manager of employee can edit vacation, employee info, or update info.
  before_action :check_manager_status, only: [:edit, :vacation, :update]
  
  #Manager of employee or employee can view themselves.
  before_action :check_employee_is_current_user_or_manager, only: [:index]
  
  #Validate date parameters.
  before_action :validate_start_date, only: [:new, :update]
  before_action :validate_roll_on_date, only: [:new, :update]
  before_action :validate_roll_off_date, only: [:new, :update]
  
  layout :set_layout
  
  def index
    if request.referer == root_url+"employee/vacation/#{@employee.id}"
      @prev_page = 3
    end
    @prev_page = 2 if flash[:project] == true
    
    respond_to do |format|
      format.json {render json: @employee}
      format.html
    end
  end
  
  def edit
  end
  
  def new 
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to :root, flash: {notice: "Employee added successfully."}
    else
      redirect_to :root, flash: {error: @employee.errors.full_messages}
    end 
  end
  
  def all
    respond_to do |format|
      format.json {render json: current_user.all_subordinates.to_json({
        include: [
          {:manager => {:only => [:first_name,:last_name]}}, 
          {:project => {:only => :name}}], 
        only: [:id, :first_name, :last_name, :role, :manager_id, :project_id, :location, :status]
      })}
    end
  end
  
  def vacation
    respond_to do |format|
      format.json {render json: @employee.vacations}
      format.html
    end
  end
  
  def update
    if @employee.update(employee_params)
      redirect_to @employee, flash: {notice: "Employee successfully updated.", project: !employee_params[:project_id].nil?}
    else
      redirect_to :back, flash: {error: @employee.errors.full_messages.first}
    end
  end
  
  private
  
  def set_user
    @employee = Employee.find(params[:id])
    @title = @employee.display_name
  end
  
  def check_manager_status
    redirect_to :root unless current_user.above? @employee or current_user.admin?
  end
  
  def check_employee_is_current_user_or_manager
    redirect_to :root unless current_user == @employee or current_user.above? @employee or current_user.is_upper_management?
  end
  
  def set_layout
    case action_name
    when "index"
      "view_resource"
    when "all"
      "resource"
    end
  end
  
  def validate_start_date
    validate_date(employee_params[:start_date]) unless employee_params[:start_date].blank?
  end
  
  def validate_roll_on_date
    validate_date(employee_params[:roll_on_date])
  end
  
  def validate_roll_off_date
    validate_date(employee_params[:roll_off_date])
  end
  
  def employee_params
    allowed_params = [:first_name, :last_name, :project_id, :start_date, :office_phone, :level, :location, :department, :cell_phone, :email, :im_name, :im_client, :team_lead_id, :roll_on_date, :roll_off_date]
    allowed_params += [:role, :manager_id, :status, :additional_days] if current_user.is_upper_management?
    param_hash = params.require(:employee).permit(allowed_params)
    param_hash.each {|key,val| param_hash[key]=val.downcase if key=='first_name' or key=='last_name'} unless param_hash.blank?
  end
end
