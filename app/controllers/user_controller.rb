class UserController < ApplicationController
  before_action :require_manager_login
  before_action :set_user
  before_action :check_manager_status
  
  def index
  end
  
  private
  
  def set_user
    @employee = Employee.find(params[:id])
  end
  
  def check_manager_status
    redirect_to :root if @employee.manager != current_user and @employee != current_user
  end
end
