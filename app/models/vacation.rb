class Vacation < ActiveRecord::Base
  belongs_to :employee
  belongs_to :manager, class_name: "Employee"
  
  validates :vacation_type, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :employee, presence: true
  validates :manager, presence: true
  validate :end_date_cannot_be_before_start_date
  validate :manager_is_above_employee
  validate :vacation_not_already_included
  
  def end_date_cannot_be_before_start_date
    unless end_date.blank? or start_date.blank? or end_date >= start_date
      errors.add(:end_date, "can't be before start date.")
    end
  end
  
  #Validate that the person who requested the vacation is above the employee.
  def manager_is_above_employee
    unless manager.above? employee
      errors.add(:end_date, "does not have permission to modify vacation for this employee.")
    end
  end
  
  def vacation_not_already_included
    Employee.find(employee_id).vacations.each do |vacation|
      unless id == vacation.id
        (vacation.start_date..vacation.end_date).each do |vacation_date|
          (start_date..end_date).each do |date|
            return errors.add(:date_range, "includes date already included for PDO.") if date == vacation_date
          end
        end
      end
    end
    
  end
end
