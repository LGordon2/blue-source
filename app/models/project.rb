class Project < ActiveRecord::Base
  belongs_to :lead, class_name: "Employee"
end
