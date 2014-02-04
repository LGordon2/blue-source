class Area < ActiveRecord::Base
  has_many :departments
  has_many :employees, through: :departments
end
