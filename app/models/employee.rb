require 'net/ldap'
class Employee < ActiveRecord::Base
  include EmployeeHelper
  
  has_many :subordinates, class_name: "Employee", foreign_key: :manager_id
  has_many :project_members, class_name: "Employee", foreign_key: :team_lead_id
  has_many :vacations
  belongs_to :manager, class_name: "Employee"
  belongs_to :team_lead, class_name: "Employee"
  belongs_to :project
  
  before_validation :set_standards_for_user
  after_validation :fix_phone_number
  
  validates :username, presence: true, uniqueness: {case_sensitive: false}
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: {with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/ }
  validates :role, presence: true
  validates :cell_phone, :office_phone, format: { with: /\A\(?\d\s*\d\s*\d\s*\)?\s*-?\d\s*\d\s*\d\s*-?\d\s*\d\s*\d\s*\d\s*\z/, message: "format is not recognized." }, allow_blank: true
  validates :status, presence: true
  validates :location, inclusion: {in: ["Greensboro","Atlanta","Remote"]}, allow_blank: true
  validate :roll_off_date_cannot_be_before_roll_on_date
  validate :manager_cannot_be_subordinate
  
  def manager_cannot_be_subordinate
    if self.manager and self.above?(self.manager)
      errors.add(:base, "You cannot be above your manager.") 
    end 
  end
  
  def accrued_vacation_days(on_date)
    accrued_vacation_days_on_date(on_date,self.start_date)
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
    return self.accrued_vacation_days(on_date.fiscal_new_year-1).round
  end
  
  def max_floating_holidays
    return 2
  end
  
  #days taken minus the time taken in the vacation with id = id.
  def sick_days_taken(on_date=Date.current, id=nil)
    _pdo_taken(on_date, "Sick", id)
  end
  
  def vacation_days_taken(on_date=Date.current, id=nil)
    _pdo_taken(on_date, "Vacation", id) + surplus_vacation_taken(on_date.change(year: on_date.year-1))
  end
  
  def surplus_vacation_taken(on_date=Date.current)
    all_vacations = self.vacations.order(start_date: :asc)
    return 0.0 if all_vacations.count == 0
    year_range = (all_vacations.first.start_date.year..on_date.year)
    
    surplus_days = year_range.inject(0.0) do |surplus,year| 
      days_taken = _pdo_taken(Date.new(year),"Vacation")
      max_days = max_vacation_days(Date.new(year))
      
      #Add to build surplus of days
      if days_taken and max_days and days_taken > max_days
        surplus + days_taken - max_days
      #If there is a surplus start widdling it down.
      elsif surplus > 0.0
        surplus + days_taken - max_days
      #Otherwise, ignore it.
      else
        surplus + 0.0
      end
    end
    surplus_days <= 0.0 ? 0.0 : surplus_days
  end
  
  def floating_holidays_taken(on_date=Date.current, id=nil)
    _pdo_taken(on_date, "Floating Holiday", id)
  end
  
  def is_manager_or_higher?
    self.role.downcase.in? ["manager","director","avp","admin"]
  end
  
  def is_upper_management?
    self.role.downcase.in? ["director", "avp", "admin"]
  end
  
  def self.locations
    ["Greensboro", "Atlanta", "Remote"]
  end
  
  def self.levels(type)
    case type.to_sym
    when :consultant
      ["Consultant I", "Consultant I/Technical", "Consultant II", "Consultant II/Technical", "Consultant III", "Consultant III/Technical"]
    when :manager
      ["Consulting Manager", "Sr. Consulting Manager"]
    when :director
      ["Director", "Sr. Director"]
    when :avp
      ["AVP"]
    else
      []
    end
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
  
  def self.departments
    ["Rural", "PSO", "MPT", "Mobile", "SAP"]
  end
  
  def admin?
    return self.role == "Admin"
  end
  
  def pdo_taken_in_range(start_date, end_date, type, except_id=nil)
    pdo_days = 0.0
    self.vacations.where(status: [nil,""]).where(vacation_type: type).where("start_date >= ? and start_date <= ?",start_date.to_s,end_date.to_s).where.not(id: except_id).each do |vacation|
      if vacation.end_date <= end_date
        pdo_days += vacation.business_days
      else
        pdo_days += Vacation.calc_business_days_for_range(vacation.start_date,end_date)
        pdo_days -= 0.5 if vacation.half_day?
      end
    end
    return pdo_days
  end
  
  def pdo_taken(on_date, type, id=nil)
    case type
    when "Vacation" then vacation_days_taken(on_date, id=nil)
    when "Floating Holiday" then floating_holidays_taken(on_date, id=nil)
    when "Sick" then sick_days_taken(on_date, id=nil)
    else raise Exception
    end
  end
  
  private
  
  def _pdo_taken(on_date, type, id=nil)
    on_date = Date.new(self.start_date.year,2,28) if on_date.leap? and on_date.month == 2 and on_date.day==29
    
    year = Vacation.calculate_fiscal_year(on_date)
    pdo_days = 0.0
    self.vacations.where(status: [nil,""]).where(vacation_type: type).where("start_date >= ? and start_date < ?", on_date.previous_fiscal_new_year, on_date.fiscal_new_year).each do |vacation|
      next if !id.nil? and vacation.id == id
      date_range = (vacation.start_date..vacation.end_date)
      unless Vacation.fiscal_new_year_date(on_date).in?(date_range)
        pdo_days += vacation.business_days
      else
        pdo_days += Vacation.calc_business_days_for_range(vacation.start_date,Vacation.fiscal_new_year_date(on_date)-1)
      end
    end
    
    last_fiscal_new_year = Vacation.fiscal_new_year_date(Date.new(on_date.year-1,on_date.month,on_date.day))
    self.vacations.where(status: [nil,""]).where(vacation_type: type).where("start_date < ?", Date.new(year-1,05,01).to_s).each do |vacation|
        next if !id.nil? and vacation.id == id
        date_range = (vacation.start_date..vacation.end_date)
        if last_fiscal_new_year.in?(date_range)
          pdo_days += Vacation.calc_business_days_for_range(last_fiscal_new_year,vacation.end_date)
        end
      end
    return pdo_days
  end
  
  def roll_off_date_cannot_be_before_roll_on_date
    unless roll_off_date.blank? or roll_on_date.blank? or roll_off_date >= roll_on_date
      errors.add(:roll_off_date, "can't be before start date.")
    end
  end
  
  #Make sure that we conform to standards
  def set_standards_for_user
    self.first_name = self.first_name.downcase unless self.first_name.blank?
    self.last_name = self.last_name.downcase unless self.last_name.blank?
    self.status = Employee.statuses.first if self.status.blank?
    self.role = Employee.roles.first if self.role.blank?
    self.email = get_unique_email("#{self.first_name}.#{self.last_name.tr_s("-' ","")}@orasi.com") if self.email.blank? and !self.first_name.blank? and !self.last_name.blank?
    self.team_lead = nil if self.project.blank?
  end
  
  #Make sure we can generate a unique email for a user.
  def get_unique_email(email)
    employee_has_email = !Employee.find_by(email: email).blank?
    return email unless employee_has_email
    new_email = email.split("@").first.split(".")
    if new_email.count == 2
      email_num = 1
    else
      email_num = new_email.last
    end
    return get_unique_email("#{self.first_name}.#{self.last_name.tr_s("-' ","")}.#{email_num.to_i+1}@orasi.com")
  end
  
  #Attempts to correct any type of phone number format (US only) added to a standard format.
  def fix_phone_number
    self.cell_phone,self.office_phone = [self.cell_phone,self.office_phone].map do |phone_num|
      unless phone_num.blank?
        clean_number = phone_num.tr_s(" ()", "").tr_s("-","")
        phone_num = "(#{clean_number[0..2]}) #{clean_number[3..5]}-#{clean_number[6..-1]}"
      end
    end
  end
end
