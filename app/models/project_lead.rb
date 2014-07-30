class ProjectLead < ActiveRecord::Base
  belongs_to :project
  belongs_to :employee

  validates :employee, uniqueness: { scope: :project, message: 'can only be listed as lead once.' }
end
