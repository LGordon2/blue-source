class WelcomeController < ApplicationController
  before_action :require_manager_login, only: :index
  
  layout "resource", only: :index
  
  def validate
    @employee = Employee.find_by(employee_params)
    
    unless !@employee.blank? and @employee.validate_against_ad(params[:employee][:password])
      additional_errors = @employee.blank? ? [] : @employee.errors.full_messages
      redirect_to :login, flash: {error: additional_errors+["Invalid username or password."]}
      return
    end
    
    if @employee.save
      session[:current_user_id] = @employee.id
      redirect_to :root
    else
      render action: :login
    end
  end
  
  # "Delete" a login, aka "log the user out"
  def logout
    # Remove the user id from the session
    @_current_user = session[:current_user_id] = nil
    redirect_to :root
  end
  
  def login
    @employee = Employee.new
  end

  def index
    @modal_title = "Add Consultant"
    @resource_for_angular = "employee"
  end
  
  def sorry
  end
  
  def issue
    email = HelpMailer.comments_email(issue_params[:from],issue_params[:email],issue_params[:comments],issue_params[:type])
    email.deliver
    redirect_to :back, flash: {email: "#{issue_params[:type].capitalize} email sent."}
  end
  
  private 
  
  def issue_params
    params.require(:issue).permit(:from, :email, :comments, :type)
  end
  
  def employee_params
    params.require(:employee).permit(:username)
  end
end
