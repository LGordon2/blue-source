class Department < ActiveRecord::Base
  belongs_to :area
  has_many :employees
end
