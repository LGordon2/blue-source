class EmployeeController < ApplicationController
  before_action :require_manager_login
  before_action :set_user, only: [:index, :edit, :vacation, :update]
  
  #Only manager of employee can edit vacation, employee info, or update info.
  before_action :check_manager_status, only: [:edit, :vacation, :update]
  
  #Manager of employee or employee can view themselves.
  before_action :check_employee_is_current_user_or_manager, only: [:index]
  
  def index
    if request.referer == root_url+"employee/vacation/#{@employee.id}"
      @prev_page = :vacation
    end
    @prev_page = :project unless flash[:project].blank?
    
    respond_to do |format|
      format.json {render json: @employee}
      format.html
    end
  end
  
  def edit
  end
  
  def new 
    @employee = Employee.new(employee_params)
    @employee.first_name = @employee.first_name.downcase
    @employee.last_name = @employee.last_name.downcase
    @employee.username = "#{@employee.first_name}.#{@employee.last_name}"
    if @employee.save
      redirect_to :root, flash: {notice: "Employee added successfully."}
    else
      redirect_to :root, flash: {error: @employee.errors.full_messages.first}
    end 
  end
  
  def all
    employee = Employee.find(current_user)
    respond_to do |format|
      format.json {render json: employee.all_subordinates.to_json({
        include: [
          {:manager => {:only => [:first_name,:last_name]}}, 
          {:project => {:only => :name}}], 
        only: [:id, :first_name, :last_name, :role, :manager_id, :project_id]
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
      redirect_to @employee, flash: {notice: "Employee successfully updated.", project: true}
    else
      render action: :edit
    end
  end
  
  private
  
  def set_user
    @employee = Employee.find(params[:id])
  end
  
  def check_manager_status
    redirect_to :root unless current_user.above? @employee
  end
  
  def check_employee_is_current_user_or_manager
    redirect_to :root unless current_user == @employee or current_user.above? @employee
  end
  
  def employee_params
    allowed_params = [:first_name, :last_name, :project_id, :start_date, :extension, :level, :phone_number, :im_name, :im_client]
    allowed_params += [:role, :manager_id] if current_user.role == "Director" or current_user.role == "AVP"
    param_hash = params.require(:employee).permit(allowed_params)
    param_hash.each {|key,val| param_hash[key]=val.downcase if key=='first_name' or key=='last_name'} unless param_hash.blank?
  end
end
