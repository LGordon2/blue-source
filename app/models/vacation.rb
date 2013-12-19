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
  validate :validate_pto_day_limit
  
  def end_date_cannot_be_before_start_date
    unless end_date.blank? or start_date.blank? or end_date >= start_date
      errors.add(:end_date, "can't be before start date.")
    end
  end
  
  #Validate that the person who requested the vacation is above the employee.
  def manager_is_above_employee
    unless manager.admin? or manager.above? employee
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
  
  def self.fiscal_new_year_date(date = Date.current)
    Date.new(self.calculate_fiscal_year(date),05,01)
  end
  
  def self.calculate_fiscal_year(date = Date.current)
    date >= Date.new(date.year, 05, 01) ? date.year+1 : date.year
  end
  
  def validate_pto_day_limit
    case self.vacation_type
    when "Sick"
      days_taken = self.employee.sick_days_taken(self.end_date.year)
      max_days = self.employee.max_sick_days
    when "Vacation"
      days_taken = self.employee.vacation_days_taken(self.end_date.year)
      max_days = self.employee.max_vacation_days(self.end_date)
    when "Floating Holiday"
      days_taken = self.employee.floating_holidays_taken(self.end_date.year)
      max_days = self.employee.max_floating_holidays
    end
    
    previous_business_days = if self.business_days_was.blank? or self.vacation_type_was != self.vacation_type then 0 else self.business_days_was end

    if days_taken - previous_business_days + self.business_days > max_days
      errors.add(:base, "Adding this PTO would put employee over alloted #{self.vacation_type.downcase} days.")
    end
  end
end
