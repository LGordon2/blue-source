class Project < ActiveRecord::Base
  belongs_to :lead, class_name: "Employee"
  after_save :set_project_for_employee
  
  validates :name, presence: true, uniqueness: true
  validate :end_date_cannot_be_before_start_date
  
  def end_date_cannot_be_before_start_date
    unless end_date.blank? or end_date > start_date
      errors.add(:end_date, "can't be before start date.")
    end
  end
  
  def set_project_for_employee
    self.lead.update(project: self) unless self.lead.blank?
  end
end
