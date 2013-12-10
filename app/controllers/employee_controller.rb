class EmployeeController < ApplicationController
  before_action :require_manager_login
  before_action :set_user, except: [:all,:new]
  before_action :check_manager_status, except: [:all, :new]
  
  def index
    respond_to do |format|
      format.json {render json: @employee}
      format.html
    end
  end
  
  def new 
    @employee = Employee.new(employee_params)
    @employee.first_name = @employee.first_name.downcase
    @employee.last_name = @employee.last_name.downcase
    @employee.username = "#{@employee.first_name}.#{@employee.last_name}"
    if @employee.save
      redirect_to :root
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
      redirect_to @employee
    else
      render action: :edit
    end
  end
  
  private
  
  def set_user
    @employee = Employee.find(params[:id])
  end
  
  def check_manager_status
    redirect_to :root unless @employee == current_user or current_user.above? @employee
  end
  
  def employee_params
    param_hash = params.require(:employee).permit(:first_name, :last_name, :role, :manager_id, :start_date, :extension, :level)
    param_hash.each {|key,val| param_hash[key]=val.downcase if key=='first_name' or key=='last_name'}
  end
end
