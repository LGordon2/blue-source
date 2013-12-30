require 'net/ldap'
class Employee < ActiveRecord::Base
  has_many :subordinates, class_name: "Employee", foreign_key: "manager_id"
  has_many :vacations
  belongs_to :manager, class_name: "Employee"
  belongs_to :lead, class_name: "Lead"
  belongs_to :project
  
  attr_accessor :display_name
  
  before_validation :set_status_role_and_email_if_blank, on: :create
  after_validation :fix_phone_number
  after_validation :set_username_if_blank, on: :create
  
  validates :username, presence: true, uniqueness: true
  validates :first_name, format: {with: /\A[a-z]+\z/, message: "must be lowercase."}
  validates :last_name, format: {with: /\A[a-z]+\z/, message: "must be lowercase."}
  validates :extension, numericality: {greater_than_or_equal_to: 1000, less_than_or_equal_to: 9999, allow_blank: true}
  validates :email, presence: true
  validates :role, presence: true
  validates :phone_number, format: { with: /\A\(?\d\s*\d\s*\d\s*\)?\s*-?\d\s*\d\s*\d\s*-?\d\s*\d\s*\d\s*\d\s*\z/, message: "format is not recognized." }, allow_blank: true
  validates :status, presence: true
  validate :pto_day_limit
  validate :roll_off_date_cannot_be_before_roll_on_date
  
  def pto_day_limit
    #Calculates the correct anniversary date for this fiscal year.
    anniversary_date = self.start_date
    anniversary_date = Date.new(self.start_date.year,2,28) if self.start_date.leap? and self.start_date.month == 2 and self.start_date.day==29
    correct_year_for_fiscal_year = if anniversary_date >= Date.new(anniversary_date.year,1,1) and anniversary_date < Date.new(anniversary_date.year,5,1) then Vacation.calculate_fiscal_year else Vacation.calculate_fiscal_year-1 end
    anniversary_date = Date.new(correct_year_for_fiscal_year, anniversary_date.month, anniversary_date.day)
    
    last_fiscal_new_year=Date.new(Vacation.calculate_fiscal_year-1,5,1)
    
    #Calculate days already taken from start of fiscal year to anniversary - 1
    days_taken_from_start_to_anniv = self.pdo_taken_in_range(last_fiscal_new_year,anniversary_date-1,"Vacation")
    
    #Calculate days taken from anniversary to end of fiscal year
    days_taken_from_anniv_to_end = self.pdo_taken_in_range(anniversary_date,Vacation.fiscal_new_year_date-1,"Vacation")
    
    vacation_days_are_correct = days_taken_from_start_to_anniv <= self.max_days("Vacation", last_fiscal_new_year) &&
    days_taken_from_start_to_anniv + days_taken_from_anniv_to_end <= self.max_days("Vacation", anniversary_date)

    unless vacation_days_are_correct and sick_days_taken <= max_sick_days and floating_holidays_taken <= max_floating_holidays
      errors.add(:time_off, 'saved for this fiscal year is preventing this employee from being saved.')
    end
  end
  
  def set_status_role_and_email_if_blank
    self.status = Employee.statuses.first if self.status.blank?
    self.role = Employee.roles.first if self.role.blank?
    self.email = "#{self.username}@orasi.com"
  end
  
  def set_username_if_blank
    username = "#{self.first_name}.#{self.last_name}" if username.blank?
  end
  
  def fix_phone_number
    return if self.phone_number.blank?
    clean_number = self.phone_number.tr_s(" ()", "").tr_s("-","")
    self.phone_number = "(#{clean_number[0..2]}) #{clean_number[3..5]}-#{clean_number[6..-1]}"
  end
   
  def self.find_or_create(user_params)
    employee = Employee.find_by(username: user_params[:username].downcase)
    return employee unless employee.nil?
    
    employee = Employee.new
    employee.username = user_params[:username].downcase
    
    return employee
  end
  
  def validate_against_ad(password)
    #Do authentication against the AD.
    return false if password.blank?
    unless Rails.env.production?
      self.first_name,self.last_name = self.username.downcase.split(".") if self.first_name.blank? or self.last_name.blank?
      self.email = "#{self.username.downcase}@orasi.com" if self.email.blank?
      return true
    end
    
    
    ldap = Net::LDAP.new :host => '10.238.242.32',
    :port => 389,
    :auth => {
      :method => :simple,
      :username => "ORASI\\#{self.username}",
      :password => password
    }
    validated = ldap.bind
    if validated and (self.first_name.blank? or self.last_name.blank?)
    
      filter = Net::LDAP::Filter.eq("samaccountname", self.username)
      treebase = "dc=orasi, dc=com"
      self.first_name,self.last_name=ldap.search(
        base: treebase,
        filter: filter,
        attributes: %w[displayname]
      ).first.displayname.first.downcase.split(" ")
      self.email=ldap.search(
        base: treebase,
        filter: filter,
        attributes: %w[mail]
      ).first.mail.first.downcase
    end
    
    return validated
  end
  
  def display_name
    self.first_name.capitalize + " " + self.last_name.capitalize
  end
  
  def all_subordinates
    return Employee.all if self.is_upper_management?
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
  
  def max_days(vacation_type,on_date=Date.current)
    case vacation_type
    when "Sick"
      return max_sick_days
    when "Vacation"
      return max_vacation_days(on_date)
    when "Floating Holiday"
      return max_floating_holidays
    end
  end
  
  def max_sick_days
    return 10
  end
  
  def max_vacation_days(on_date = Date.current)
    return 10 if self.start_date.blank?
    anniversary_date = self.start_date
    anniversary_date = Date.new(self.start_date.year,2,28) if self.start_date.leap? and self.start_date.month == 2 and self.start_date.day==29
    #Correct year to put in for fiscal year.
    correct_year_for_fiscal_year = if anniversary_date >= Date.new(anniversary_date.year,1,1) and anniversary_date < Date.new(anniversary_date.year,5,1) then Vacation.calculate_fiscal_year(on_date) else Vacation.calculate_fiscal_year(on_date)-1 end
    #m is days from anniversary date (day of year hired) to fiscal new year year (May 1st)
    m = (Vacation.fiscal_new_year_date(on_date) - Date.new(correct_year_for_fiscal_year,anniversary_date.month,anniversary_date.day)).to_i
    #p is days from fiscal new year year to anniversary date+
    p = (Date.new(correct_year_for_fiscal_year+1,anniversary_date.month,anniversary_date.day) - Vacation.fiscal_new_year_date(on_date)).to_i
    #n is days of vacation given before upcoming anniversary. 0-3 years = 10 | 3-6 years = 15 | 6+ years = 20
    
    years_with_orasi_on_anniversary = correct_year_for_fiscal_year - anniversary_date.year
    if years_with_orasi_on_anniversary < 0
      return 10
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
  
  #days taken minus the time taken in the vacation with id = id.
  def sick_days_taken(on_date=Date.current, id=nil)
    pdo_taken(on_date, "Sick", id)
  end
  
  def vacation_days_taken(on_date=Date.current, id=nil)
    pdo_taken(on_date, "Vacation", id)
  end
  
  def floating_holidays_taken(on_date=Date.current, id=nil)
    pdo_taken(on_date, "Floating Holiday", id)
  end
  
  def is_manager_or_higher?
    self.role.downcase.in? ["manager","director","avp","admin"]
  end
  
  def is_upper_management?
    self.role.downcase.in? ["director", "avp", "admin"]
  end
  
  def self.roles
    ["Consultant","Manager","Director","AVP", "Admin"]
  end
  
  def self.im_client_types
    ["Windows Messenger", "Google Talk", "Skype", "AIM", "IRC"]
  end
  
  def self.statuses
    ["Permanent", "Contractor", "Inactive"]
  end
  
  def admin?
    return self.role == "Admin"
  end
  
  def pdo_taken_in_range(start_date, end_date, type, except_id=nil)
    pdo_days = 0.0
    self.vacations.where(vacation_type: type).where("start_date >= ? and start_date <= ?",start_date.to_s,end_date.to_s).where.not(id: except_id).each do |vacation|
      if vacation.end_date <= end_date
        pdo_days += vacation.business_days
      else
        pdo_days += Vacation.calc_business_days_for_range(vacation.start_date,end_date)
      end
    end
    return pdo_days
  end
  
  def pdo_taken(on_date, type, id=nil)
    on_date = Date.new(self.start_date.year,2,28) if on_date.leap? and on_date.month == 2 and on_date.day==29
    
    year = Vacation.calculate_fiscal_year(on_date)
    pdo_days = 0.0
    self.vacations.where(vacation_type: type).where("start_date >= ?", Date.new(year-1,05,01).to_s).each do |vacation|
      next if !id.nil? and vacation.id == id
      date_range = (vacation.start_date..vacation.end_date)
      unless Vacation.fiscal_new_year_date(on_date).in?(date_range)
        pdo_days += vacation.business_days
      else
        pdo_days += Vacation.calc_business_days_for_range(vacation.start_date,Vacation.fiscal_new_year_date(on_date)-1)
      end
    end
    
    last_fiscal_new_year = Vacation.fiscal_new_year_date(Date.new(on_date.year-1,on_date.month,on_date.day))
    self.vacations.where(vacation_type: type).where("start_date < ?", Date.new(year-1,05,01).to_s).each do |vacation|
        next if !id.nil? and vacation.id == id
        date_range = (vacation.start_date..vacation.end_date)
        if last_fiscal_new_year.in?(date_range)
          pdo_days += Vacation.calc_business_days_for_range(last_fiscal_new_year,vacation.end_date)
        end
      end
      return pdo_days
  end
  
  private
  
  def roll_off_date_cannot_be_before_roll_on_date
    unless roll_off_date.blank? or roll_on_date.blank? or roll_off_date >= roll_on_date
      errors.add(:roll_off_date, "can't be before start date.")
    end
  end
  
end
