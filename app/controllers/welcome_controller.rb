class WelcomeController < ApplicationController
  before_action :require_manager_login, only: :index
  
  layout "resource", only: :index
  
  def validate
    if params[:employee][:username] =~ (/^[a-z]+\.[a-z]+@orasi\.com$/) 
      params[:employee][:email] = params[:employee][:username]
      @employee = Employee.find_by(email: params[:employee][:email])
    else
      @employee = Employee.find_by(username: params[:employee][:username])
    end
    
    unless !@employee.blank? and @employee.validate_against_ad(params[:employee][:password])
      additional_errors = @employee.blank? ? [] : @employee.errors.full_messages
      redirect_to :login, flash: {error: additional_errors+["Invalid username or password."]}
      return
    end
    
    if @employee.save
      session[:current_user_id] = @employee.id
      Session.create(session_id: session[:session_id])
      if @employee.role == "Base"
        redirect_to view_employee_vacations_path(@employee)
      else
        redirect_to :root
      end
    else
      redirect_to :login, flash: {error: @employee.errors.full_messages}
    end
  end
  
  # "Delete" a login, aka "log the user out"
  def logout
    # Remove the user id from the session
    @_current_user = session[:current_user_id] = nil
    redirect_to :login
  end
  
  def login
    @employee = Employee.new
    
    @mybrowser = request.env['HTTP_USER_AGENT']
    @compatibility_mode = !(request.env['HTTP_USER_AGENT'] =~ /compatible/).nil?
    case @mybrowser
    when /Firefox/
      @browser_name = "Firefox"
    when /Chrome/
      @browser_name = "Chrome"
    when /MSIE\s*\d+\.0/
      @browser_name = /MSIE\s*\d+\.0/.match(@mybrowser)
    when /rv:11.0/
      @browser_name = "IE 11"
    end
  end

  def index
    @modal_title = "Add Consultant"
    @resource_for_angular = "employee"
  end
  
  def issue
    email = HelpMailer.comments_email(current_user.display_name,current_user.email,issue_params[:comments],issue_params[:type])
    email.deliver
    redirect_to :back, flash: {info: "#{issue_params[:type].capitalize} email sent."}
  end
  
  private 
  
  def issue_params
    params.require(:issue).permit(:comments, :type)
  end
end
