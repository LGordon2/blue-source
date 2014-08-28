# rubocop:disable Style/LineLength, Style/CyclomaticComplexity, Style/MethodLength
class Employee < ActiveRecord::Base
  include EmployeeHelper

  serialize :preferences, Hash

  # Associations
  has_many :subordinates, class_name: 'Employee', foreign_key: :manager_id
  has_many :project_members, class_name: 'Employee', foreign_key: :team_lead_id
  has_many :vacations
  has_many :projects, class_name: 'ProjectHistory'
  has_many :reports
  belongs_to :manager, class_name: 'Employee'
  belongs_to :team_lead, class_name: 'Employee'
  belongs_to :department
  belongs_to :employee_title, class_name: 'Title', foreign_key: :title_id
  belongs_to :title
  has_one :area, through: :department

  # Validations
  before_validation :set_standards_for_user

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/ }
  validates :role, presence: true, inclusion: { in: ->(employee) { employee.class.roles } }
  validates :department, presence: { message: "must be present for the role you've selected.", if: :department_area_head_or_admin? }
  validates :status, presence: true, inclusion: { in: ->(employee) { employee.class.statuses } }
  validates :location, inclusion: { in: ->(employee) { employee.class.locations } }, allow_blank: true
  validates :bridge_time, numericality: { only_integer: true }, allow_blank: true
  validate :manager_cannot_be_subordinate
  validate :minimum_and_maximum_dates
  validate :employee_cannot_be_their_own_manager
  validate :resources_per_page_must_be_greater_than_zero

  def current_project
    all_project_histories = projects.where('roll_on_date <= :date and (roll_off_date IS NULL or roll_off_date >= :date)', date: Date.current)
    return nil if all_project_histories.blank?
    all_project_histories.first.project
  end

  def title
    employee_title.name unless employee_title.blank?
  end

  def contractor?
    status == 'Contractor'
  end

  def department_area_head_or_admin?
    role.in?(['Upper Management', 'Department Head'])
  end

  def manager_cannot_be_subordinate
    errors.add(:base, 'You cannot be above your manager.') if manager && above?(manager)
  end

  def employee_cannot_be_their_own_manager
    errors.add(:base, 'You cannot be your own manager.') if manager && manager == self
  end

  def resources_per_page_must_be_greater_than_zero
    errors.add(:base, 'Resources per page must be greater than 0.') unless preferences.blank? || preferences[:resourcesPerPage].to_i > 0
  end

  def accrued_vacation_days(on_date)
    date_to_use = nil
    date_to_use = start_date - (bridge_time.blank? ? 0 : bridge_time.months) unless start_date.blank?
    accrued_vacation_days_on_date(on_date, date_to_use)
  end

  def validate_against_ad(password)
    # Do authentication against the AD.
    return false if password.blank?
    unless Rails.env.production?
      self.first_name, self.last_name = username.downcase.split('.') if first_name.blank? || last_name.blank?
      self.email = "#{username.downcase}@orasi.com" if email.blank?
      return true
    end

    set_ldap(username.downcase, password)

    validated = @ldap.bind
    if validated && (first_name.blank? || last_name.blank?)

      filter = Net::LDAP::Filter.eq('samaccountname', username)
      treebase = 'dc=orasi, dc=com'
      self.first_name, self.last_name = @ldap.search(
        base: treebase,
        filter: filter,
        attributes: %w(displayname)
      ).first.displayname.first.downcase.split(' ')
      self.email = @ldap.search(
        base: treebase,
        filter: filter,
        attributes: %w(mail)
      ).first.mail.first.downcase
    end

    validated
  end

  def search_validate(employee_email, password)
    return false if password.blank?
    return false unless Rails.env.production?

    set_ldap(username.downcase, password)

    validated = @ldap.bind
    employee_email = employee_email.downcase

    if validated
      filter = Net::LDAP::Filter.eq('mail', employee_email)
      treebase = 'dc=orasi, dc=com'
      @username = @ldap.search(
        base: treebase,
        filter: filter,
        attributes: %w(samaccountname)
      )
    else
      false
    end
  end

  def employee_searched_username
    if @username.present?
      @username.first.samaccountname.first
    else
      "Not found, please check if employee's email is entered correctly."
    end
  end

  def display_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def all_subordinates_for_manager(all_subordinates_ids=[])
    return if subordinates.empty?
    all_subordinates_ids += subordinates.pluck(:id)
    subordinates.each do |employee|
      all_subordinates_ids += employee.all_subordinates_for_manager.pluck(:id) unless employee.all_subordinates_for_manager.nil?
    end
    Employee.where(id: all_subordinates_ids.uniq)
  end

  def all_subordinates
    return Employee.all if role == 'Company Admin'
    all_subordinates_ids = []
    if !department.blank? && (role.in?(['Upper Management', 'Department Head', 'Department Admin']))
      return department.employees if subordinates.empty?
      all_subordinates_ids += Employee.where(id: (department.employees.pluck(:id) + subordinates.pluck(:id)).flatten.uniq)
    end
    all_subordinates_for_manager(all_subordinates_ids)
  end

  def above?(other_employee)
    return false if other_employee.manager.blank?

    return true if other_employee.manager == self

    above? other_employee.manager
  end

  # We can view the employee if:
  # * We are the employee
  # * We are above the employee
  # * We are a upper manager/department head/admin in the same department of the employee
  # * We are a company admin
  def can_view?(other_employee)
    # We are the employee
    return true if other_employee == self

    # We are above the employee
    return true if above? other_employee

    # We are a company admin
    return true if role == 'Company Admin'

    # We are a upper manager/department head/admin in the same department of the employee
    return false unless other_employee.department.present?

    return true if other_employee.department == department && role.in?(['Upper Management'])

    return true if (department.present? && department.above?(other_employee.department)) && role.in?(['Department Head', 'Department Admin'])

    false
  end

  # We can edit the employee if:
  # * We are above the employee
  # * We are upper management/department head and are in the same department as the employee
  # * We are an area head/admin and are in the same area as the employee
  # * We are a company admin
  def can_edit?(other_employee)
    return false if self == other_employee && !role.in?(['Company Admin', 'Department Admin'])

    return true if above? other_employee

    # We are a upper manager/department/area head/admin in the same department/area of the employee
    return true if ((!department.blank? && department.above?(other_employee.department)) && role.in?(['Department Head', 'Department Admin'])) && other_employee.department.present?

    # We are a company admin
    return true if role == 'Company Admin'

    false
  end

  def can_add_to_system?
    role.in? ['Department Head', 'Department Admin', 'Company Admin']
  end

  # We can add the employee if:
  # * We are upper management/department head and are in the same department as the employee
  # * We are an area head/admin and are in the same area as the employee
  # * We are a company admin
  def can_add?(other_employee)
    return false unless can_add_to_system?

    # We are a upper manager/department/area head/admin in the same department/area of the employee
    return true if ((!department.blank? && department.above?(other_employee.department)) && role.in?(['Department Head', 'Department Admin'])) && other_employee.department.present?

    # We are a company admin
    return true if role == 'Company Admin'

    false
  end

  def max_days(vacation_type, on_date = Date.current)
    case vacation_type
    when 'Sick'
      return max_sick_days
    when 'Vacation'
      return max_vacation_days(on_date)
    when 'Floating Holiday'
      return max_floating_holidays(on_date)
    end
  end

  def max_sick_days
    10
  end

  def max_vacation_days(on_date = Date.current)
    max_days = accrued_vacation_days(on_date.fiscal_new_year - 1)
    return 0 if max_days <= 0.0
    special_vacation_round(max_days)
  end

  def max_floating_holidays(on_date = Date.current)
    return 2 if start_date.blank?

    return 1 if start_date >= Vacation.fiscal_new_year_date(on_date) - 90.days

    2
  end

  # days taken minus the time taken in the vacation with id = id.
  def sick_days_taken(on_date = Date.current, id = nil)
    _pdo_taken(on_date, 'Sick', id)
  end

  def vacation_days_taken(on_date = Date.current, id = nil)
    _days_taken = _pdo_taken(on_date, 'Vacation', id) + surplus_vacation_taken(on_date.change(year: on_date.year - 1))
  end

  def surplus_vacation_taken(on_date = Date.current)
    all_vacations = vacations.order(start_date: :asc)
    return 0.0 if all_vacations.count == 0
    year_range = (all_vacations.first.start_date.year..on_date.year)

    surplus_days = year_range.reduce(0.0) do |surplus, year|
      days_taken = _pdo_taken(Date.new(year), 'Vacation')
      max_days = max_vacation_days(Date.new(year))

      # Add to build surplus of days
      if days_taken && max_days && max_days > 0.0 && days_taken > max_days
        surplus + days_taken - max_days
      # If there is a surplus start widdling it down.
      elsif surplus > 0.0
        surplus + days_taken - max_days
      # Otherwise, ignore it.
      else
        surplus + 0.0
      end
    end
    surplus_days <= 0.0 ? 0.0 : surplus_days
  end

  def floating_holidays_taken(on_date = Date.current, id = nil)
    _pdo_taken(on_date, 'Floating Holiday', id)
  end

  def manager_or_higher?
    role.in? Employee.roles - ['Base'] + ['Company Admin']
  end

  def upper_management?
    role.in? ['Upper Management', 'Department Head', 'Department Admin', 'Company Admin']
  end

  def self.locations
    %w(Greensboro Atlanta Remote)
  end

  def self.roles
    ['Base', 'Management', 'Upper Management', 'Department Head', 'Department Admin', 'Company Admin']
  end

  def self.im_client_types
    ['Windows Messenger', 'Google Talk', 'Skype', 'AIM', 'IRC']
  end

  def self.statuses
    %w(Permanent Contractor Inactive)
  end

  def admin?
    role.in? ['Department Admin', 'Company Admin']
  end

  def pdo_taken_in_range(start_date, end_date, type, except_id = nil)
    pdo_days = 0.0
    vacations.where(status: [nil, '']).where(vacation_type: type).where('start_date >= ? and start_date <= ?', start_date.to_s, end_date.to_s).where.not(id: except_id).each do |vacation|
      if vacation.end_date <= end_date
        pdo_days += vacation.business_days
      else
        pdo_days += Vacation.calc_business_days_for_range(vacation.start_date, end_date)
        pdo_days -= 0.5 if vacation.half_day?
      end
    end
    pdo_days
  end

  def pdo_taken(on_date, type, id = nil)
    case type
    when 'Vacation' then vacation_days_taken(on_date, id)
    when 'Floating Holiday' then floating_holidays_taken(on_date, id)
    when 'Sick' then sick_days_taken(on_date, id)
    else fail ArgumentError, "Invalid PDO type #{type}"
    end
  end

  private

  def set_ldap(username, password)
    @ldap = Net::LDAP.new host: ENV['LDAP_SERVER'],
                          port: ENV['LDAP_PORT'],
                          auth: {
                              method: :simple,
                              username: "ORASI\\#{username}",
                              password: password
                          }
  end

  def _pdo_taken(on_date, type, id = nil)
    on_date = Date.new(start_date.year, 2, 28) if on_date.leap? && on_date.month == 2 && on_date.day == 29

    year = Vacation.calculate_fiscal_year(on_date)
    pdo_days = 0.0
    vacations.where(status: [nil, '']).where(vacation_type: type).where('start_date >= ? and start_date < ?', on_date.previous_fiscal_new_year, on_date.fiscal_new_year).each do |vacation|
      next if !id.nil? && vacation.id == id
      date_range = (vacation.start_date..vacation.end_date)
      if !Vacation.fiscal_new_year_date(on_date).in?(date_range)
        pdo_days += vacation.business_days
      else
        pdo_days += Vacation.calc_business_days_for_range(vacation.start_date, Vacation.fiscal_new_year_date(on_date) - 1)
      end
    end

    last_fiscal_new_year = Vacation.fiscal_new_year_date(Date.new(on_date.year - 1, on_date.month, on_date.day))
    vacations.where(status: [nil, '']).where(vacation_type: type).where('start_date < ?', Date.new(year - 1, 05, 01).to_s).each do |vacation|
      next if !id.nil? && vacation.id == id
      date_range = (vacation.start_date..vacation.end_date)
      if last_fiscal_new_year.in?(date_range)
        pdo_days += Vacation.calc_business_days_for_range(last_fiscal_new_year, vacation.end_date)
        pdo_days -= 0.5 if vacation.half_day?
      end
    end

    pdo_days
  end

  # Make sure that we conform to standards
  def set_standards_for_user
    self.first_name = first_name.downcase unless first_name.blank?
    self.last_name = last_name.downcase unless last_name.blank?
    self.status = Employee.statuses.first if status.blank?
    self.role = Employee.roles.first if role.blank?
    self.email = get_unique_email("#{first_name}.#{last_name.tr_s("-' ", '')}@orasi.com") if email.blank? && first_name.present? && last_name.present?
  end

  # Make sure we can generate a unique email for a user.
  def get_unique_email(email)
    employee_has_email = Employee.find_by(email: email).present?
    return email unless employee_has_email

    new_email = email.split('@').first.split('.')
    email_num = new_email.count == 2 ? 1 : new_email.last
    get_unique_email("#{first_name}.#{last_name.tr_s("-' ", '')}.#{email_num.to_i + 1}@orasi.com")
  end

  def minimum_and_maximum_dates
    minimum_date = Date.new(2000)
    maximum_date = Date.new(2100)

    return if start_date.blank?

    errors.add(:start_date, "is before the minimum date of #{minimum_date}.") unless minimum_date < start_date

    errors.add(:start_date, "is after the maximum date of #{maximum_date}.") unless maximum_date > start_date
  end
end
