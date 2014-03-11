class ProjectLead < ActiveRecord::Base
  belongs_to :project
  belongs_to :employee
  
  after_create :set_employees
  
  validates :employee, uniqueness: { scope: :project, message: "can only be listed as lead once."}
  
  private
  
  def set_employees
    if self.project.leads.count == 1
      self.project.employees.each do |employee|
        employee.update(team_lead: self.project.leads.first)
      end
    end
  end
end
