class DepartmentsController < ApplicationController
  before_action :set_department
  
  def sub_departments
    respond_to do |format|
      format.json { render json: @department.sub_departments.to_json() } 
    end
  end
  
  private
  
  def set_department
    @department = Department.find(params[:department_id])
  end
end
