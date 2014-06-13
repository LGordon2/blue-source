require 'net/ldap'

class Employee < ActiveRecord::Base
  include OrasiDateCalculations

  serialize :preferences, Hash

  #Associations
  has_many :subordinates, class_name: "Employee", foreign_key: :manager_id
  has_many :project_members, class_name: "Employee", foreign_key: :team_lead_id
  has_many :vacations
  belongs_to :manager, class_name: "Employee"
  belongs_to :team_lead, class_name: "Employee"
  has_many :projects, class_name: "ProjectHistory"
  belongs_to :department
  belongs_to :employee_title, class_name: "Title", foreign_key: :title_id
  has_one :area, through: :department
  has_many :reports

  #Validations
  before_validation :set_standards_for_user

  validates :username, presence: true, uniqueness: {case_sensitive: false}
  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: {with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/ }
  validates :role, presence: true, inclusion: {in: ->(employee) {employee.class.roles}}
  validates :department, presence: {message: "must be present for the role you've selected.", if: :is_department_area_head_or_admin}
  validates :status, presence: true, inclusion: {in: ->(employee) {employee.class.statuses}}
  validates :location, inclusion: {in: ->(employee) {employee.class.locations}}, allow_blank: true
  validates :bridge_time, numericality: { only_integer: true }, allow_blank: true
  validate :manager_cannot_be_subordinate
  validate :minimum_and_maximum_dates
  validate :employee_cannot_be_their_own_manager
  validate :resources_per_page_must_be_greater_than_zero

  def current_project
    all_project_histories = projects.where("roll_on_date <= :date and (roll_off_date IS NULL or roll_off_date >= :date)",date: Date.current)
    return nil if all_project_histories.blank?
    all_project_histories.first.project
  end

  def title
    unless self.title_id.blank?
      title_found = Title.find_by(id: self.title_id)
      unless title_found.blank?
        title_found.name
      end 
    end
  end

  def is_department_area_head_or_admin
    self.role.in? ["Upper Management", "Department Head"]
  end

  def manager_cannot_be_subordinate
    if self.manager and self.above?(self.manager)
      errors.add(:base, "You cannot be above your manager.")
    end
  end
  
  def employee_cannot_be_their_own_manager
    if self.manager and self.manager == self
      errors.add(:base, "You cannot be your own manager.")
    end
  end
  
  def resources_per_page_must_be_greater_than_zero
    unless self.preferences.blank? or self.preferences[:resourcesPerPage].to_i > 0
      errors.add(:resources_per_page, "must be greater than 0.")
    end

    unless preferences.blank? or preferences[:resourcesPerPage].is_a? Integer
      errors.add(:resources_per_page, "must be greater than 0.")
    end
  end

  def accrued_vacation_days(on_date)
    date_to_use = nil
    unless self.start_date.blank?
      date_to_use = self.start_date - (self.bridge_time.blank? ? 0 : self.bridge_time.months)
    end
    accrued_vacation_days_on_date(on_date,date_to_use)
  end

  def validate_against_ad(password)
    #Do authentication against the AD.
    return false if password.blank?
    unless Rails.env.production?
      self.first_name,self.last_name = self.username.downcase.split(".") if self.first_name.blank? or self.last_name.blank?
      self.email = "#{self.username.downcase}@orasi.com" if self.email.blank?
      return true
    end
    ldap = Net::LDAP.new host: '10.238.242.32',
    port: 389,
    auth: {
      method: :simple,
      username: "ORASI\\#{self.username.downcase}",
      password: password
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
    return Employee.all if role == "Company Admin"
    all_subordinates_ids = []
    if !self.department.blank? and (role.in? ["Upper Management", "Department Head", "Department Admin"])
      return self.department.employees if self.subordinates.empty?
      all_subordinates_ids += Employee.where(id: (self.department.employees.pluck(:id) + self.subordinates.pluck(:id)).flatten.uniq)
    end
    return if self.subordinates.empty?
    all_subordinates_ids += self.subordinates.pluck(:id)
    self.subordinates.each do |employee|
      all_subordinates_ids += employee.all_subordinates.pluck(:id) unless employee.all_subordinates.nil?
    end
    return Employee.where(id: all_subordinates_ids.uniq)
  end

  def above? other_employee
    if other_employee.manager.blank?
      return false
    end

    if other_employee.manager == self
      return true
    end

    self.above? other_employee.manager
  end

  #We can view the employee if:
  # * We are the employee
  # * We are above the employee
  # * We are a upper manager/department/area head/admin in the same department/area of the employee
  # * We are a company admin
  def can_view? other_employee
    #We are the employee
    if other_employee == self
      return true
    end

    #We are above the employee
    if self.above? other_employee
      return true
    end

    #We are a upper manager/department/area head/admin in the same department/area of the employee
    if !other_employee.department.blank?
      if other_employee.department == self.department and self.role.in? ["Upper Management"]
        return true
      elsif (!self.department.blank? and self.department.above? other_employee.department) and self.role.in? ["Department Head", "Department Admin"]
        return true
      end
    end

    #We are a company admin
    if self.role == "Company Admin"
      return true
    end

    false
  end

  #We can view the employee if:
  # * We are above the employee
  # * We are upper management/department head and are in the same department as the employee
  # * We are an area head/admin and are in the same area as the employee
  # * We are a company admin
  def can_edit? other_employee
    if self == other_employee and !self.role.in? ["Company Admin", "Department Admin"]
      return false
    end

    if self.above? other_employee
      return true
    end

    #We are a upper manager/department/area head/admin in the same department/area of the employee
    if !other_employee.department.blank?
      if (!self.department.blank? and self.department.above? other_employee.department) and self.role.in? ["Department Head", "Department Admin"]
        return true
      end
    end

    #We are a company admin
    if self.role == "Company Admin"
      return true
    end

    false
  end

  def can_add_to_system?
    self.role.in? ["Department Head", "Department Admin", "Company Admin"]
  end

  #We can add the employee if:
  # * We are upper management/department head and are in the same department as the employee
  # * We are an area head/admin and are in the same area as the employee
  # * We are a company admin
  def can_add? other_employee
    unless self.can_add_to_system?
      return false
    end

    #We are a upper manager/department/area head/admin in the same department/area of the employee
    if !other_employee.department.blank?
      if (!self.department.blank? and self.department.above? other_employee.department) and self.role.in? ["Department Head", "Department Admin"]
        return true
      end
    end

    #We are a company admin
    if self.role == "Company Admin"
      return true
    end

    false
  end

  def max_days(vacation_type,on_date=Date.current)
    case vacation_type
    when "Sick"
      return max_sick_days
    when "Vacation"
      return max_vacation_days(on_date)
    when "Floating Holiday"
      return max_floating_holidays(on_date)
    end
  end

  def max_sick_days
    return 10
  end

  def max_vacation_days(on_date = Date.current)
    _max_days = self.accrued_vacation_days(on_date.fiscal_new_year-1)
    return 0 if _max_days <= 0.0
    special_vacation_round(_max_days)
  end

  def max_floating_holidays(on_date = Date.current)
    if self.start_date.blank?
      return 2
    end

    if self.start_date >= Vacation.fiscal_new_year_date(on_date) - 90.days
      return 1
    end

    return 2
  end

  #days taken minus the time taken in the vacation with id = id.
  def sick_days_taken(on_date=Date.current, id=nil)
    _pdo_taken(on_date, "Sick", id)
  end

  def vacation_days_taken(on_date=Date.current, id=nil)
    _days_taken = _pdo_taken(on_date, "Vacation", id) + surplus_vacation_taken(on_date.change(year: on_date.year-1))
  end

  def surplus_vacation_taken(on_date=Date.current)
    all_vacations = self.vacations.order(start_date: :asc)
    return 0.0 if all_vacations.count == 0
    year_range = (all_vacations.first.start_date.year..on_date.year)

    surplus_days = year_range.inject(0.0) do |surplus,year|
      days_taken = _pdo_taken(Date.new(year),"Vacation")
      max_days = max_vacation_days(Date.new(year))

      #Add to build surplus of days
      if days_taken and max_days and max_days > 0.0 and days_taken > max_days
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
    self.role.in? Employee.roles - ["Base"] + ["Company Admin"]
  end

  def is_upper_management?
    self.role.in? ["Upper Management","Department Head", "Department Admin", "Company Admin"]
  end

  def self.locations
    ["Greensboro", "Atlanta", "Remote"]
  end

  def self.roles
    ["Base","Management","Upper Management","Department Head", "Department Admin", "Company Admin"]
  end

  def self.im_client_types
    ["Windows Messenger", "Google Talk", "Skype", "AIM", "IRC"]
  end

  def self.statuses
    ["Permanent", "Contractor", "Inactive"]
  end

  def admin?
    return (self.role == "Department Admin" or self.role == "Company Admin")
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

    year = calculate_fiscal_year(on_date)
    pdo_days = 0.0
    self.vacations.where(status: [nil,""]).where(vacation_type: type).where("start_date >= ? and start_date < ?", on_date.previous_fiscal_new_year, on_date.fiscal_new_year).each do |vacation|
      next if !id.nil? and vacation.id == id
      date_range = (vacation.start_date..vacation.end_date)
      unless fiscal_new_year_date(on_date).in?(date_range)
        pdo_days += vacation.business_days
      else
        pdo_days += calc_business_days_for_range(vacation.start_date,fiscal_new_year_date(on_date)-1)
      end
    end

    last_fiscal_new_year = fiscal_new_year_date(Date.new(on_date.year-1,on_date.month,on_date.day))
    self.vacations.where(status: [nil,""]).where(vacation_type: type).where("start_date < ?", last_fiscal_new_year.to_s).each do |vacation|
        next if !id.nil? and vacation.id == id
        date_range = (vacation.start_date..vacation.end_date)
        if last_fiscal_new_year.in?(date_range)
          pdo_days += calc_business_days_for_range(last_fiscal_new_year,vacation.end_date)
          pdo_days -= 0.5 if vacation.half_day?
        end
      end

    return pdo_days
  end

  #Make sure that we conform to standards
  def set_standards_for_user
    self.first_name = self.first_name.downcase unless self.first_name.blank?
    self.last_name = self.last_name.downcase unless self.last_name.blank?
    self.status = Employee.statuses.first if self.status.blank?
    self.role = Employee.roles.first if self.role.blank?
    self.email = get_unique_email("#{self.first_name}.#{self.last_name.tr_s("-' ","")}@orasi.com") if self.email.blank? and !self.first_name.blank? and !self.last_name.blank?
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
  
  def minimum_and_maximum_dates
    minimum_date = Date.new(2000)
    maximum_date = Date.new(2100)
    
    unless start_date.blank?
      unless minimum_date <= start_date
        errors.add(:start_date, "is before the minimum date of #{minimum_date}.")
      end
      unless maximum_date > start_date
        errors.add(:start_date, "is after the maximum date of #{maximum_date}.")
      end
    end
  end
end
