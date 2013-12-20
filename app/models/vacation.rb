class Vacation < ActiveRecord::Base
  include VacationHelper
  
  belongs_to :employee
  belongs_to :manager, class_name: "Employee"
  
  before_validation :calculate_business_days
  
  validates :vacation_type, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :employee, presence: true
  validates :manager, presence: true
  validates :business_days, presence: true
  validate :end_date_cannot_be_before_start_date
  validate :manager_is_above_employee
  validate :vacation_not_already_included
  validate :pdo_days_taken
  
  private
  
  def calculate_business_days
    self.business_days = Vacation.calc_business_days_for_range(self.start_date,self.end_date)
    self.business_days -= 0.5 if self.half_day
  end
  
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
  
  def pdo_days_taken
    unless validate_days_taken(self.start_date,self.end_date)
      errors.add(:base, "Adding this PTO would put employee over alloted #{self.vacation_type.downcase} days.")
    end
  end
  
  def validate_days_taken(start_date,end_date,days_taken=0.0)
    if start_date.blank? or end_date.blank?
      errors[:date] << "Invalid date entered."
      return
    end
    
    date_range = (start_date..end_date)
    fiscal_new_year = Vacation.fiscal_new_year_date(start_date)
    unless self.employee.start_date.blank?
      anniversary_date = self.employee.start_date
      anniversary_date = Date.new(self.employee.start_date.year,2,28) if self.employee.start_date.leap? and self.employee.start_date.month == 2 and self.employee.start_date.day==29
      correct_year_for_fiscal_year = if anniversary_date >= Date.new(anniversary_date.year,1,1) and anniversary_date < Date.new(anniversary_date.year,5,1) then Vacation.calculate_fiscal_year(start_date) else Vacation.calculate_fiscal_year(start_date)-1 end
      anniversary_date = Date.new(correct_year_for_fiscal_year, anniversary_date.month, anniversary_date.day)
    end
    
    if fiscal_new_year.in?(date_range) and start_date != fiscal_new_year
      return validate_days_taken(start_date,fiscal_new_year-1) && validate_days_taken(fiscal_new_year,end_date)
    elsif anniversary_date.in?(date_range) and start_date != anniversary_date
      return validate_days_taken(start_date,anniversary_date-1) && validate_days_taken(anniversary_date,end_date,Vacation.calc_business_days_for_range(start_date,anniversary_date-1))
    end
    
    case self.vacation_type
    when "Sick"
      days_already_taken = self.employee.sick_days_taken(start_date, self.id)
      max_days = self.employee.max_sick_days
    when "Vacation"
      days_already_taken = self.employee.vacation_days_taken(start_date, self.id)
      max_days = self.employee.max_vacation_days(start_date)
    when "Floating Holiday"
      days_already_taken = self.employee.floating_holidays_taken(start_date, self.id)
      max_days = self.employee.max_floating_holidays
    end
    
    business_days_taken_in_range = Vacation.calc_business_days_for_range(start_date, end_date)
    business_days_already_taken = days_already_taken + days_taken
    
    return business_days_taken_in_range + business_days_already_taken <= max_days
  end
end
