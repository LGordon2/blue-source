class Admin::DepartmentsController < ApplicationController
  before_action :require_login
  before_action :must_be_company_admin, except: [:sub_departments, :employees]
  
  def index
    @margin = 20
  end
  
  private
  
  def must_be_company_admin
    unless current_user.role == "Company Admin"
      redirect_to :root, flash: {error: "WTF are you doing..."}
    end
  end
end