class DirectoryController < ApplicationController
  layout "resource"
  include ActionView::Helpers::AssetUrlHelper #Just for assets path
  
  before_action :require_login
  
  def employees
    respond_to do |format|
      format.json {
        all_employees = Employee.all.as_json({
            include: [
            {manager: {only: [:id, :first_name, :last_name, :email]}}
          ], only: [:id, :first_name, :last_name, :office_phone, :cell_phone, :status, :department, :manager_id, :email, :im_name, :im_client]
        }).map do |e| 
           e = e.merge("first_name"=>e['first_name'].capitalize,
                              "last_name"=>e['last_name'].capitalize)
           unless e['manager'].nil? 
             e.merge("manager"=>e['manager'].merge({
               "first_name"=>e['manager']['first_name'].capitalize,
               "last_name"=>e['manager']['last_name'].capitalize
             })) 
           else
             e
           end 
        end
        render json: all_employees.to_json
      }
    end
  end
  
  def index
    @resource_for_angular = "employee"
  end
end
