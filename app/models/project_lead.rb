class ProjectLead < ActiveRecord::Base
  belongs_to :project
  belongs_to :employee
end
