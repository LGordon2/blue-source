class EmployeesController < ApplicationController
  before_action :require_login

  #Sets the employee
  before_action :set_employee, only: [:show, :update, :preferences, :projects]
  before_action :employee_must_be_current_user, only: :preferences
  before_action :require_manager_login, except: [:directory, :preferences]

  before_action :can_edit, only: [:update]
  before_action :can_view, only: [:show]

  #Validate date parameters.
  before_action :validate_start_date, only: [:create, :update]
  before_action :validate_roll_on_date, only: [:create, :update]
  before_action :validate_roll_off_date, only: [:create, :update]

  layout :set_layout

  def show
    if request.referer == employee_vacations_url(@employee.id)
      @prev_page = 3
    end
    @prev_page = 2 if flash[:project] == true

    @current_project = ProjectHistory.where(employee: @employee).where("roll_on_date <= :date and (roll_off_date IS NULL or roll_off_date >= :date)",date: Date.current).first

    respond_to do |format|
      format.json {render json: @employee}
      format.html
    end


  end

  def directory
    respond_to do |format|
      format.json
    end
  end

  def preferences
    preferences = params.require(:employee).permit(preferences: :resourcesPerPage)
    if @employee.update(preferences)
      redirect_to @employee, flash: {success: "Employee successfully updated."}
    else
      redirect_to @employee, flash: {error: @employee.errors.full_messages.first}
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
      format.html
      format.json
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
    @employee = Employee.find(params[:id] || params[:employee_id])
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
    allowed_params = [:username, :first_name, :last_name, :project_id, :start_date, :office_phone, :level, :location, :cell_phone, :email, :im_name, :im_client, :team_lead_id, :roll_on_date, :roll_off_date, :scheduled_hours_start, :scheduled_hours_end, :project_comments, :title_id]
    allowed_params += [:role, :manager_id, :status, :additional_days, :bridge_time] if current_user.upper_management?
    param_hash = params.require(:employee).permit(allowed_params, department_id: [])
    param_hash[:department_id] = param_hash[:department_id].reject {|val| val == ""}.last if param_hash.has_key?(:department_id)
    param_hash.each {|key,val| param_hash[key]=val.downcase if key=='first_name' or key=='last_name'} unless param_hash.blank?
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

  def employee_must_be_current_user
    unless current_user == @employee
      redirect_to :root, flash: {error: "You do not have permission to edit preferences for this employee."}
    end
  end
end
