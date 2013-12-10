require 'net/ldap'
class Employee < ActiveRecord::Base
  has_many :subordinates, class_name: "Employee", foreign_key: "manager_id"
  has_many :vacations
  belongs_to :manager, class_name: "Employee"
  belongs_to :lead, class_name: "Lead"
  belongs_to :project
  
  attr_accessor :display_name
  
  before_validation :set_names, on: :create
  
  validates :username, presence: true, uniqueness: true, format: /\A\w+\.\w+\z/
  validates :first_name, format: {with: /\A[a-z]+\z/, message: "must be lowercase."}
  validates :last_name, format: {with: /\A[a-z]+\z/, message: "must be lowercase."}
  validates :extension, numericality: {greater_than_or_equal_to: 1000, less_than_or_equal_to: 9999, allow_blank: true}
  validates :role, presence: true, inclusion: {in: ["Consultant", "Manager", "Director", "AVP"]}
  validates_with StartDateValidator
  
  def set_names
    self.first_name,self.last_name = self.username.downcase.split(".") unless self.username.blank?
  end
   
  def self.authenticate(user_params)
    employee = Employee.find_by(username: user_params[:username])
    return employee unless employee.nil?
    employee = Employee.new
    employee.username = user_params[:username].downcase
    
    return employee
  end
  
  def display_name
    self.first_name.capitalize + " " + self.last_name.capitalize
  end
  
  def all_subordinates
    return if self.subordinates.empty?
    all_subordinates = self.subordinates
    self.subordinates.each do |employee|
      all_subordinates += employee.all_subordinates unless employee.all_subordinates.nil?
    end
    return all_subordinates
  end
  
  def above? other_employee
    if other_employee.manager == self
      return true
    end
    
    self.above? other_employee.manager unless other_employee.manager.nil?
  end
  
  def max_sick_days
    return 10
  end
  
  def max_vacation_days(on_date = Date.current)
    return 10 if self.start_date.blank?
    anniversary_date = self.start_date
    #Correct year to put in for fiscal year.
    correct_year_for_fiscal_year = if anniversary_date >= Date.new(anniversary_date.year,1,1) and anniversary_date < Date.new(anniversary_date.year,5,1) then Vacation.calculate_fiscal_year else Vacation.calculate_fiscal_year-1 end

    #m is days from anniversary date (day of year hired) to fiscal new year year (May 1st)
    m = (Vacation.fiscal_new_year_date - Date.new(correct_year_for_fiscal_year,anniversary_date.month,anniversary_date.day)).to_i
    #p is days from fiscal new year year to anniversary date+
    p = (Date.new(correct_year_for_fiscal_year+1,anniversary_date.month,anniversary_date.day) - Vacation.fiscal_new_year_date).to_i
    #n is days of vacation given before upcoming anniversary. 0-3 years = 10 | 3-6 years = 15 | 6+ years = 20
    
    years_with_orasi_on_anniversary = correct_year_for_fiscal_year - anniversary_date.year
    if years_with_orasi_on_anniversary < 0
      raise Exception
    end
    n = case (years_with_orasi_on_anniversary)
    when 0..3 then 10
    when 4..6 then 15
    else 20
    end
    #d is days of vacation given after upcoming anniversary. 0-3 years = 10 | 3-6 years = 15 | 6+ years = 20
    d = case (years_with_orasi_on_anniversary)
    when 0..2 then 10
    when 3..5 then 15
    else 20
    end
    
    if on_date >= Date.new(correct_year_for_fiscal_year,anniversary_date.month,anniversary_date.day) then ((p/365.0)*n+(m/365.0)*d).round else n end
  end
  
  def max_floating_holidays
    return 2
  end
  
  def sick_days_taken(year)
    pdo_taken(year, "Sick")
  end
  
  def vacation_days_taken(year)
    pdo_taken(year, "Vacation")
  end
  
  def floating_holidays_taken(year)
    pdo_taken(year, "Floating Holiday")
  end
  
  private
  
  def pdo_taken(year, type)
    pdo_days = 0
    self.vacations.where(vacation_type: type)
    .where("start_date >= ? and end_date <= ?", Date.new(year,05,01), Date.new(year+1,04,30)).each do |vacation|
      pdo_days += vacation.business_days
    end
    return pdo_days
  end
end
