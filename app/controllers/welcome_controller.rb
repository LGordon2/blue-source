class WelcomeController < ApplicationController
  before_action :require_manager_login, only: :index
  
  layout "resource", only: :index
  
  def validate
    unless validate_against_ad(params[:employee][:username],params[:employee][:password])
      redirect_to :login, flash: {error: "Invalid username or password."}
      return
    end
    
    @employee = Employee.authenticate(params[:employee])
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
    redirect_to :sorry unless current_user.is_manager_or_higher?
  end
  
  def sorry
  end
  
  def issue
    email = HelpMailer.comments_email(issue_params[:from],issue_params[:email],issue_params[:comments],issue_params[:type])
    email.deliver
    redirect_to :back
  end
  
  private 
  
  def validate_against_ad(username, password)
    #Do authentication against the AD.
    return true unless Rails.env.production?
    
    ldap = Net::LDAP.new :host => '10.238.242.32',
    :port => 389,
    :auth => {
      :method => :simple,
      :username => "ORASI\\#{username}",
      :password => password
    }
    ldap.bind
  end
  
  def issue_params
    params.require(:issue).permit(:from, :email, :comments, :type)
  end
end
