class Project < ActiveRecord::Base
  has_many :employees
  
  validates :name, presence: true, uniqueness: true
  validate :end_date_cannot_be_before_start_date
  
  #Set leads retroactively.
  after_validation :set_leads
  
  def leads
    self.employees.where(project_lead: true)
  end
  
  private
  
  def set_leads
    return if self.leads.count > 1
    Employee.where(project: self).update_all(team_lead_id: self.leads.first)
  end
  
  def end_date_cannot_be_before_start_date
    unless end_date.blank? or start_date.blank? or end_date > start_date
      errors.add(:end_date, "can't be before start date.")
    end
  end
end
