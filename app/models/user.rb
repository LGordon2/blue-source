require 'net/ldap'
class User < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true
  validates :username, format: /\A\w+\.\w+\z/
   
  def self.authenticate(user_params)
    user = User.find_by(username: user_params[:username])
    return user unless user.nil?
    user = User.new
    user.username = user_params[:username].downcase
    user.first_name,user.last_name = user_params[:username].downcase.split(".")
    return user
  end
end
