class DirectoryController < ApplicationController
  layout "resource"
  include ActionView::Helpers::AssetUrlHelper #Just for assets path
  
  def employees
    respond_to do |format|
      format.json {render json: Employee.all.as_json({
        include: [
          {manager: {only: [:first_name, :last_name, :email]}}
        ], only: [:id, :first_name, :last_name, :office_phone, :cell_phone, :status, :department, :manager_id, :email, :im_name, :im_client]
      }).map {|e| e.merge("im_client_url"=>"/assets"+asset_path("#{e['im_client'].downcase unless e['im_client'].blank?}.png"))}.to_json}
    end
  end
  
  def index
    @resource_for_angular = "employee"
  end
end
