class DepartmentsController < ApplicationController
  include ApplicationHelper
  
  before_action :set_department
  def sub_departments
    respond_to do |format|
      format.json { render json: @department.sub_departments }
    end
  end

  def employees
    respond_to do |format|
      format.json { render json: @department.employees.where.not(status: "Inactive").as_json({
      include: [
        {manager: {only: [:id,:first_name,:last_name, :email]}},
        {department: {only: [:name]}}
      ],
      only: [:id, :first_name, :last_name, :email, :department, :office_phone, :cell_phone, :im_name, :im_client]
    }).map {|e| capitalize_names_and_projects(e)}
      }
    end
  end

  private

  def set_department
    @department = Department.find(params[:department_id])
  end
end
