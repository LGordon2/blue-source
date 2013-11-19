class EmployeeController < ApplicationController
  before_action :require_manager_login
  before_action :set_user
  before_action :check_manager_status
  
  def index
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
    redirect_to :root if @employee.manager != current_user and @employee != current_user
  end
  
  def employee_params
    param_hash = params.require(:employee).permit(:first_name, :last_name, :role, :manager_id, :start_date, :extension)
    param_hash.each {|key,val| param_hash[key]=val.downcase if key=='first_name' or key=='last_name'}
  end
end
