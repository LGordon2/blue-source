class DepartmentsController < ApplicationController
  include ApplicationHelper
  
  before_action :must_be_company_admin, except: [:sub_departments, :employees]
  before_action :set_department, except: [:new, :create]
  
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
  
  def create
    @department = Department.new(department_params)
    if @department.save
      redirect_to admin_departments_path, flash: {success: "Department successfully created."}
    else
      redirect_to :back, flash: {error: @department.errors.full_messages}
    end
  end
  
  def destroy
    if @department.destroy
      redirect_to admin_departments_path, flash: {success: "Department successfully deleted."}
    else
      redirect_to admin_departments_path, flash: {error: @department.errors.full_messages}
    end
  end
  
  def update
    if @department.update(department_params)
      redirect_to admin_departments_path, flash: {success: "Department successfully updated."}
    else
      redirect_to edit_department_path(@department), flash: {error: @department.errors.full_messages}
    end
  end
  
  def new
    @department = Department.new(department_id: params[:parent_dept])
  end

  private

  def set_department
    @department = Department.find(params[:department_id] || params[:id])
  end
  
  def department_params
    params.require(:department).permit(:name,:department_id)
  end
  
  def must_be_company_admin
    unless current_user.role == "Company Admin" or current_user.sys_admin
      redirect_to :root, flash: {error: "WTF are you doing..."}
    end
  end
end
