class Vacation < ActiveRecord::Base
  include VacationHelper
  
  belongs_to :employee
  belongs_to :manager, class_name: "Employee"
  
  before_validation :set_business_days
  
  validates :vacation_type, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :employee, presence: true
  validates :manager, presence: true
  validates :business_days, presence: true, numericality: {greater_than: 0}
  validate :end_date_cannot_be_before_start_date
  validate :manager_is_above_employee
  validate :vacation_not_already_included
  validate :pdo_days_taken #also calculates business days taken
  validate :reason_present_if_other
  
  def self.types
    ["Sick","Vacation","Floating Holiday","Other"]
  end
  
  private
  
  def reason_present_if_other
    if self.reason.blank? and self.vacation_type == "Other"
      errors.add(:base, "Reason must be present for vacation type 'Other'.")
    end
  end
  
  def end_date_cannot_be_before_start_date
    unless end_date.blank? or start_date.blank? or end_date >= start_date
      errors.add(:end_date, "can't be before start date.")
    end
  end
  
  def set_business_days
    #Calculates the correct number of business days taken.
    Rails.logger.error "Start date was blank." if self.start_date.blank?
    Rails.logger.error "End date was blank." if self.end_date.blank?
    return if self.start_date.blank? or self.end_date.blank?
    
    self.business_days = Vacation.calc_business_days_for_range(self.start_date,self.end_date)
    self.business_days -= 0.5 if self.half_day
  end
  
  #Validate that the person who requested the vacation is above the employee.
  def manager_is_above_employee
    unless manager.admin? or manager.above? employee
      errors.add(:end_date, "does not have permission to modify vacation for this employee.")
    end
  end
  
  def vacation_not_already_included
    Rails.logger.error "Start date was blank." if self.start_date.blank?
    Rails.logger.error "End date was blank." if self.end_date.blank?
    return if self.start_date.blank? or self.end_date.blank?
    
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
    Rails.logger.error "Start date was blank." if self.start_date.blank?
    Rails.logger.error "End date was blank." if self.end_date.blank?
    return if self.start_date.blank? or self.end_date.blank? or self.vacation_type == "Other"
    
    unless validate_pto(self.start_date,self.end_date)
      errors.add(:base, "Adding this PTO would put employee over alloted #{self.vacation_type.downcase} days.")
    end
  end
  
  def validate_pto(start_date, end_date)
    #Get the correct days taken and max days for the vacation type.
    days_taken_this_fiscal_year = self.employee.pdo_taken(start_date, self.vacation_type, self.id)
    
    date_range = (start_date..end_date)
    fiscal_new_year = Vacation.fiscal_new_year_date(start_date)
    
    #Check to see if the fiscal year is in the date range or the anniversary date is in the date range.
    if fiscal_new_year.in?(date_range) and start_date != fiscal_new_year
      return validate_pto(start_date,fiscal_new_year-1) && validate_pto(fiscal_new_year,end_date)
    end
    
    #If their anniversary is blank just validate for the range given.
    business_days_taken_range = Vacation.calc_business_days_for_range(start_date,end_date)
    
    #Account for half day
    business_days_taken_range -= 0.5 if self.half_day
    if self.employee.start_date.blank?
      return business_days_taken_range + days_taken_this_fiscal_year <= self.employee.max_days(self.vacation_type,start_date)
    end
    
    #Calculates the correct anniversary date for this fiscal year.
    anniversary_date = self.employee.start_date
    anniversary_date = Date.new(self.employee.start_date.year,2,28) if self.employee.start_date.leap? and self.employee.start_date.month == 2 and self.employee.start_date.day==29
    correct_year_for_fiscal_year = if anniversary_date >= Date.new(anniversary_date.year,1,1) and anniversary_date < Date.new(anniversary_date.year,5,1) then Vacation.calculate_fiscal_year(start_date) else Vacation.calculate_fiscal_year(start_date)-1 end
    anniversary_date = Date.new(correct_year_for_fiscal_year, anniversary_date.month, anniversary_date.day)
    
    last_fiscal_new_year=Date.new(Vacation.calculate_fiscal_year(start_date)-1,5,1)
    
    #Calculate days already taken from start of fiscal year to anniversary - 1
    days_taken_from_start_to_anniv = self.employee.pdo_taken_in_range(last_fiscal_new_year,anniversary_date-1,self.vacation_type,self.id)
    
    #Calculate days taken from anniversary to end of fiscal year
    days_taken_from_anniv_to_end = self.employee.pdo_taken_in_range(anniversary_date,Vacation.fiscal_new_year_date(start_date)-1,self.vacation_type,self.id)
    
    if anniversary_date.in?(date_range)
      #Calculate days requested from start to anniversary - 1
      business_days_requested_start_to_anniv = Vacation.calc_business_days_for_range(start_date,anniversary_date-1)
      #Calculate days requested from anniversary to end
      business_days_requested_anniv_to_end = Vacation.calc_business_days_for_range(anniversary_date,end_date)
    elsif end_date < anniversary_date
      #Calculate days requested from start to end date
      business_days_requested_start_to_anniv = Vacation.calc_business_days_for_range(start_date,end_date)
      #Calculate days requested from anniversary to end
      business_days_requested_anniv_to_end = 0
    elsif end_date >= anniversary_date
      #Calculate days requested from start to anniversary - 1
      business_days_requested_start_to_anniv = 0
      #Calculate days requested from anniversary to end
      business_days_requested_anniv_to_end = Vacation.calc_business_days_for_range(start_date,end_date)
    else
      raise Exception
    end
    
    #Take into account sick days.
    if business_days_requested_anniv_to_end > 0 and self.half_day
      business_days_requested_anniv_to_end -= 0.5 
    elsif business_days_requested_start_to_anniv > 0 and self.half_day
      business_days_requested_start_to_anniv -= 0.5
    end
    
    #Make sure that the days before the anniversary date don't exceed the max days for the start date
    #and the days after the anniversary date don't exceed the max days for the anniversary date.
    return business_days_requested_start_to_anniv + days_taken_from_start_to_anniv <= self.employee.max_days(self.vacation_type, start_date) &&
    business_days_requested_start_to_anniv + business_days_requested_anniv_to_end + days_taken_from_start_to_anniv + days_taken_from_anniv_to_end <= self.employee.max_days(self.vacation_type, anniversary_date)
 end
end
