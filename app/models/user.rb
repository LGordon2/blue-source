require 'net/ldap'
class User < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true
   
  def self.authenticate(user_params)
    user = User.find_by(username: user_params[:username])
    return user unless user.nil?
    user = User.new
    user.username = user_params[:username]
    return user
  end
end
