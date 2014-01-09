class DirectoryController < ApplicationController
  layout "resource"
  
  def employees
    respond_to do |format|
      format.json {render json: Employee.all.to_json({
        include: [
          {manager: {only: [:first_name, :last_name, :email]}}
        ], only: [:id, :first_name, :last_name, :office_phone, :cell_phone, :status, :department, :manager_id, :email]
      })}
    end
  end
  
  def index
    @resource_for_angular = "employee"
  end
end
