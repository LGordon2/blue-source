class UserController < ApplicationController
  before_action :require_manager_login
  before_action :set_user
  before_action :check_manager_status
  
  def index
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def check_manager_status
    redirect_to :root if @user.manager != current_user and @user != current_user
  end
end
