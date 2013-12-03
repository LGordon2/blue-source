class Project < ActiveRecord::Base
  belongs_to :lead, class_name: "Employee"
  after_save :set_project_for_employee
  
  validates :name, presence: true, uniqueness: true
  validates_with StartDateValidator
  validate :projected_end_cannot_be_before_start_date
  
  def projected_end_cannot_be_before_start_date
    unless projected_end.blank? or projected_end > start_date
      errors.add(:projected_end, "can't be after start date.")
    end
  end
  
  def set_project_for_employee
    self.lead.update(project: self) unless self.lead.blank?
  end
end
