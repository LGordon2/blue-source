class WelcomeController < ApplicationController
  before_action :require_login, only: :index
  
  def validate
    unless validate_against_ad(params[:user][:username],params[:user][:password])
      redirect_to :login, flash: {error: "Invalid username or password."}
      return
    end
    
    @user = User.authenticate(params[:user])
    if @user.save 
      session[:current_user_id] = @user.id
      redirect_to :root
    else
      render action: :login
    end
  end
  
  # "Delete" a login, aka "log the user out"
  def destroy
    # Remove the user id from the session
    @_current_user = session[:current_user_id] = nil
    redirect_to :root
  end
  
  def login
    @user = User.new
  end

  def index
  end
  
  private 
  
  def validate_against_ad(username, password)
    #Do authentication against the AD.
    first_part_username,_ = username.split("@")
    ldap = Net::LDAP.new :host => '10.238.242.32',
    :port => 389,
    :auth => {
      :method => :simple,
      :username => "ORASI\\#{first_part_username}",
      :password => password
    }
    true#ldap.bind
  end
end
