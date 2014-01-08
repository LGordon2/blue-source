class Project < ActiveRecord::Base
  has_many :employees
  
  validates :name, presence: true, uniqueness: true
  validate :end_date_cannot_be_before_start_date
  
  def end_date_cannot_be_before_start_date
    unless end_date.blank? or end_date > start_date
      errors.add(:end_date, "can't be before start date.")
    end
  end
  
  def leads
    self.employees.where(project_lead: true)
  end
end
