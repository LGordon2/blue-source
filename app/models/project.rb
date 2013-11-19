class Project < ActiveRecord::Base
  belongs_to :lead, class_name: "Employee"
  
  validates :name, presence: true
end
