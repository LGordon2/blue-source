class Vacation < ActiveRecord::Base
  include OrasiDateCalculations
  
  scope :vacations_in_range, ->(start_date,end_date) do 
    where(%Q(
       (vacations.start_date BETWEEN :filter_start_date and :filter_end_date) or
       (vacations.end_date BETWEEN :filter_start_date and :filter_end_date) or
       (:filter_start_date BETWEEN vacations.start_date and vacations.end_date)
     ),filter_start_date: start_date, filter_end_date: end_date)
  end
  
  belongs_to :employee
  belongs_to :manager, class_name: "Employee"
  
  before_validation :set_business_days
  
  validates :vacation_type, presence: true, inclusion: { in: ->(vacation){vacation.class.types} }
  validates :date_requested, :start_date, :end_date, :employee, :manager, presence: true
  validates :business_days, presence: true, numericality: {greater_than: 0}
  validate :employee_is_not_inactive
  validate :minimum_and_maximum_dates
  validate :end_date_cannot_be_before_start_date
  validate :vacation_not_already_included
  validate :reason_present_if_other
  validate :vacation_not_added_before_start_date
  validate :pdo_type_must_be_other_if_contractor
  
  def self.types
    ["Sick","Vacation","Floating Holiday","Other"]
  end
  
  def pdo_type_must_be_other_if_contractor
    if self.employee.status == "Contractor" and !self.vacation_type.in? ["Sick", "Vacation", "Other"]
      errors.add(:base, "Contractors can only take sick or vacation time.")
    elsif self.employee.status == "Contractor" and self.vacation_type != "Other"
      self.reason = "Contractor #{self.vacation_type}"
      self.vacation_type = "Other"
      self.save
    end
  end
  
  def pdo_taken(fiscal_year=Date.current.year)
    if fiscal_year > end_date.current_fiscal_year or fiscal_year < start_date.current_fiscal_year
      return 0.0
    end
    date_range = (start_date..end_date)
    if Date.new(fiscal_year).fiscal_new_year.in? date_range
      return Vacation.calc_business_days_for_range(start_date,start_date.fiscal_new_year-1)
    elsif Date.new(fiscal_year).previous_fiscal_new_year.in? date_range
      return Vacation.calc_business_days_for_range(end_date.previous_fiscal_new_year,end_date) - (half_day==true ? 0.5 : 0)
    else
      return business_days
    end
  end

  def pending?
    self.status == "Pending"
  end

  private
  
  def vacation_not_added_before_start_date
    if !(self.employee.start_date.blank? or self.start_date.blank?) and (self.employee.start_date > self.start_date)
      errors.add(:start_date, "is before employee's start date.")
    end
  end
  
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
  
  def vacation_not_already_included
    Rails.logger.error "Start date was blank." if self.start_date.blank?
    Rails.logger.error "End date was blank." if self.end_date.blank?
    return if self.start_date.blank? or self.end_date.blank?
    
    (start_date..end_date).each do |date|
      start_date_count = (half_day and date == end_date) ? 0.5 : 1
      days_taken = Employee.find(employee_id).vacations.vacations_in_range(date,date).where.not(id: id).inject(start_date_count) do |sum, v|
        sum + ((v.end_date == date and v.half_day) ? 0.5 : 1)
      end
      return errors.add(:date_range, "includes date already included for PDO.") if days_taken > 1
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
  
  def minimum_and_maximum_dates
    return if date_requested.blank? or start_date.blank? or end_date.blank?
    
    minimum_date = Date.new(2000)
    maximum_date = Date.new(2100)
    
    unless minimum_date < date_requested
      errors.add(:date_requested, "is before the minimum date of #{minimum_date}.")
    end
    unless minimum_date < start_date
      errors.add(:start_date, "is before the minimum date of #{minimum_date}.")
    end
    unless minimum_date < end_date
      errors.add(:end_date, "is before the minimum date of #{minimum_date}.")
    end
    
    unless maximum_date > date_requested
      errors.add(:date_requested, "is after the maximum date of #{maximum_date}.")
    end
    unless maximum_date > start_date
      errors.add(:start_date, "is before the maximum date of #{maximum_date}.")
    end
    unless maximum_date > end_date
      errors.add(:end_date, "is before the maximum date of #{maximum_date}.")
    end
  end
  
  def employee_is_not_inactive
    if self.employee.status == "Inactive"
      errors.add("Employee's status", "was inactive.")
    end
  end
end
