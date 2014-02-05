class EmployeesController < ApplicationController
  #Sets the employee 
  before_action :set_employee, only: [:show, :update]
  
  before_action :require_manager_login
  
  before_action :can_edit, only: [:update]
  before_action :can_view, only: [:show]
  
  #Validate date parameters.
  before_action :validate_start_date, only: [:create, :update]
  before_action :validate_roll_on_date, only: [:create, :update]
  before_action :validate_roll_off_date, only: [:create, :update]
  
  layout :set_layout
  
  def show
    if request.referer == root_url+"employee/vacation/#{@employee.id}"
      @prev_page = 3
    end
    @prev_page = 2 if flash[:project] == true
    
    respond_to do |format|
      format.json {render json: @employee}
      format.html
    end
  end
  
  def directory
    respond_to do |format|
      format.json {render json: all_employees_for_directory.to_json}
    end
  end
  
  def create
    @employee = Employee.new(employee_params)
    unless current_user.can_add? @employee
      redirect_to :root, flash: {error: "You do not have permission to add this employee."}
      return
    end
    
    if @employee.save
      redirect_to :root, flash: {success: "Employee added successfully."}
    else
      redirect_to :root, flash: {error: @employee.errors.full_messages}
    end 
  end
  
  def index
    @modal_title = "Add Consultant"
    @resource_for_angular = "employee"
    respond_to do |format|
      format.json {
        render json: subordinates_hash.to_json
      }
      format.html
    end
  end
  
  def update
    if @employee.update(employee_params)
      redirect_to @employee, flash: {success: "Employee successfully updated.", project: !employee_params[:project_id].nil?}
    else
      redirect_to @employee, flash: {error: @employee.errors.full_messages.first}
    end
  end
  
  private
  
  def set_employee
    @employee = Employee.find(params[:id])
    @title = @employee.display_name
  end
  
  def set_layout
    case action_name
    when "show"
      "view_resource"
    when "index"
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
    allowed_params = [:username, :first_name, :last_name, :project_id, :start_date, :office_phone, :level, :location, :department_id, :cell_phone, :email, :im_name, :im_client, :team_lead_id, :roll_on_date, :roll_off_date]
    allowed_params += [:role, :manager_id, :status, :additional_days] if current_user.is_upper_management?
    param_hash = params.require(:employee).permit(allowed_params)
    param_hash.each {|key,val| param_hash[key]=val.downcase if key=='first_name' or key=='last_name'} unless param_hash.blank?
  end
  
  def subordinates_hash
    current_user.all_subordinates.as_json({
    include: [
      {:manager => {:only => [:id,:first_name,:last_name]}}, 
      {:project => {:only => :name}}], 
    only: [:id, :first_name, :last_name, :role, :manager_id, :project_id, :location, :status]
  }).map do |e| 
      capitalize_names_and_projects(e)
    end
  end
  
  def all_employees_for_directory
    Employee.where.not(status: "Inactive").as_json({
      include: [
        {manager: {only: [:id,:first_name,:last_name, :email]}},
        {department: {only: [:name]}}
      ],
      only: [:id, :first_name, :last_name, :email, :department, :office_phone, :cell_phone, :im_name, :im_client]
    }).map do |e|
      capitalize_names_and_projects(e)
    end
  end
  
  def capitalize_names_and_projects(employee)
     employee = employee.merge("first_name"=>employee['first_name'].capitalize,
             "last_name"=>employee['last_name'].capitalize)
     employee = employee.merge("project"=>{"name"=>"Not billable"}) if employee['project'].blank?
     unless employee['manager'].nil?
       employee.merge("manager"=>employee['manager'].merge({
         "first_name"=>employee['manager']['first_name'].capitalize,
         "last_name"=>employee['manager']['last_name'].capitalize
       })) 
     else 
       employee 
     end 
  end
  
  #Permissions

  def can_view
    unless current_user.can_view? @employee
      redirect_to :root, flash: {error: "You do not have permission to view this employee."}
    end
  end
  
  def can_edit
    unless current_user.can_edit? @employee
      redirect_to :root, flash: {error: "You do not have permission to edit this employee."}
    end
  end
end
