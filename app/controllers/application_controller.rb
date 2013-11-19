class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  force_ssl if: :ssl_configured?
  
  helper_method :current_user
  
  private
 
  # Finds the Employee with the ID stored in the session with the key
  # :current_user_id This is a common way to handle user login in
  # a Rails application; logging in sets the session value and
  # logging out removes it.
  def current_user
    @_current_user ||= session[:current_user_id] &&
      Employee.find_by(id: session[:current_user_id])
  end
  
  def require_manager_login
    if current_user.nil?
      redirect_to :login
    elsif current_user.subordinates.empty?
      redirect_to :sorry
    end
  end
  
  def ssl_configured?
    !Rails.env.development? and !Rails.env.test?
  end
end
