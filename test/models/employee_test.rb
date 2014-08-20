# rubocop:disable Style/LineLength, Style/ClassLength
require 'test_helper'

# Testing employee model functionality.
class EmployeeTest < ActiveSupport::TestCase
  test "two employees shouldn't have the same username" do
    e1 = Employee.new
    e2 = Employee.new
    e1.username = 'john.doe'
    e1.email = 'john.doe@orasi.com'
    e1.save
    e2.username = 'john.doe'
    e2.email = 'john.doe@orasi.com'
    assert_raises ActiveRecord::RecordInvalid do
      e2.save!
    end
  end

  test 'start date can be after the current date' do
    e = Employee.new
    e.username = 'bob.dylan'
    e.first_name = 'bob'
    e.last_name = 'dylan'
    e.start_date = Date.new(2099, 1, 1)
    assert_nothing_raised ActiveRecord::RecordInvalid do
      e.save!
    end
  end

  test 'above functionality' do
    consultant = employees(:consultant)
    manager = employees(:manager)
    director = employees(:upper_manager)

    # Test simple case
    assert manager.above? consultant
    assert_not consultant.above? manager

    # Test another simple case
    assert director.above? manager
    assert_not manager.above? director

    # Test transitivity
    assert director.above? consultant
    assert_not consultant.above? director
  end

  test 'max vacation days' do
    employee = employees(:consultant)

    employee.start_date = Date.current.ago(1)
    assert_operator 10, '>=', employee.max_vacation_days,
                    'Employee should have less than or 10 days of vacation time.'

    employee.start_date = Date.current.years_ago(4)
    assert_equal 15, employee.max_vacation_days

    employee.start_date = Date.current.years_ago(7)
    assert_equal 20, employee.max_vacation_days

    employee.start_date = Date.current.years_ago(3).days_since(7)
    assert_operator 10, '<=', employee.max_vacation_days
  end

  test 'employee should be allowed to have start year on leap year day' do
    e = employees(:consultant)
    e.email = 'bob.barker.2@orasi.com'
    e.start_date = Date.new(2012, 2, 29)
    e.save!
  end

  test 'current project for employee' do
    e = employees(:consultant)
    p = projects(:one)

    ph = ProjectHistory.create(
                                project: p,
                                employee: e,
                                roll_on_date: Date.current,
                                roll_off_date: Date.current + 2.days
                              )

    assert ph.valid?, ph.errors.full_messages

    assert_equal e.current_project, p
  end

  test 'title can be retrieved for employee' do
    t = titles(:consultant)
    e = employees(:consultant)
    assert_nil e.title

    e.employee_title = t
    e.save

    assert_equal t.name, e.title
  end

  test 'manager can not be subordinate' do
    e = employees(:consultant)
    m = employees(:manager)
    m.manager = e
    assert_not m.valid?, m.errors.full_messages
  end

  test 'employee can not be their own manager' do
    e = employees(:consultant)
    e.manager = e
    assert_not e.valid?, e.errors.full_messages
  end

  test 'resources per page must be greater than zero' do
    e = employees(:consultant)
    e.preferences[:resourcesPerPage] = -1
    assert_not e.valid?, e.errors.full_messages

    e.preferences[:resourcesPerPage] = 0
    assert_not e.valid?, e.errors.full_messages

    e.preferences[:resourcesPerPage] = 1
    assert e.valid?, e.errors.full_messages
  end

  test 'max floating holidays validation' do
    e = employees(:consultant)
    e.start_date = nil
    assert_nil e.start_date

    # If they don't have a start date they get two floating holidays
    assert_equal 2, e.max_floating_holidays

    # If their start date is 90 days before the fiscal new year then they
    # only get one floating holiday
    e.start_date = Date.new(2014, 5, 1) - 90.days
    assert_equal 1, e.max_floating_holidays(Date.new(2014, 4, 30))

    # Otherwise they should get two days
    assert_equal 2, e.max_floating_holidays(Date.new(2015, 4, 30))
  end

  test 'exception when pdo type is not valid' do
    e = employees(:consultant)
    assert_raises ArgumentError do
      e.pdo_taken(Date.current, 'InvalidType')
    end
  end

  # TODO: Add factory girl here...
  test 'unique email is always generated' do
    # Setup base employee with default email
    e = employees(:consultant)
    e.email = 'john.doe@orasi.com'
    e.save
    assert e.valid?, e.errors.full_messages

    # Create an employee and try to use the original user's email.
    e2 = Employee.create(
                          username: "#{e.username}2",
                          first_name: e.first_name,
                          last_name: e.last_name,
                          email: e.email,
                          role: e.role,
                          status: e.status
                        )
    # This should not be valid and have only the unique email error message
    assert_not e2.valid?, e2.errors.full_messages
    assert_equal 1, e2.errors.full_messages.count
    e2.email = nil
    e2.save

    # Make sure that it is valid now and has a differently
    # generated email than the first consultant.
    assert e2.valid?, e2.errors.full_messages
    assert_not_equal e.email, e2.email

    # Repeat this process for the third employee.
    e3 = Employee.create(
                          username: "#{e.username}3",
                          first_name: e.first_name,
                          last_name: e.last_name,
                          role: e.role,
                          status: e.status
                        )
    e3.save
    assert e3.valid?, e3.errors.full_messages
    assert_not_equal e.email, e3.email
    assert_not_equal e2.email, e3.email
  end

  test 'can view permissions' do
    # Employee can view themselves
    consultant = employees(:consultant)
    assert consultant.can_view?(consultant)

    # Employee is above other employee.
    manager = employees(:manager)
    manager2 = employees(:manager2)
    assert manager.can_view?(consultant)
    assert_not manager2.can_view?(consultant)

    # Upper manager/department head/admin in the same department of the employee
    upper_manager = employees(:upper_manager)
    department_head = employees(:department_head)
    department_admin = employees(:department_admin)

    [upper_manager, department_head, department_admin].each do |manager|
      assert_equal manager.department, consultant.department
      assert manager.can_view?(consultant)
    end

    # Department admin is in department above employee
    services_admin = employees(:services_admin)
    assert services_admin.department.above? consultant.department
    assert services_admin.can_view?(consultant)

    # Upper manager in different department not above employee cannot view employee
    upper_manager2 = employees(:upper_manager2)
    assert_not_equal upper_manager2.department, consultant.department
    assert_not upper_manager2.department.above? consultant.department
    assert_not upper_manager2.can_view?(consultant)

    # Company admin
    company_admin = employees(:company_admin)
    assert company_admin.can_view?(consultant)
  end

  test 'employee can not login without password' do
    employee_model = employees(:consultant)
    assert_not employee_model.validate_against_ad('')
  end

  # test 'employee can login with username and password in development environment' do
  #   Rails.env = 'development'
  #   employee1 = employees(:consultant)
  #   assert employee1.validate_against_ad('password')
  #   Rails.env = 'test'
  # end
  #
  # test 'employee cannot login with incorrect credentials in production environment' do
  #   Rails.env = 'production'
  #   employee1 = employees(:consultant)
  #   assert_not employee1.validate_against_ad('foot_loose')
  #   Rails.env = 'test'
  # end

  test 'admin cannot search for employee username without their password' do
    admin1 = employees(:company_admin)
    assert_not admin1.search_validate('example@orasi.com', '')
  end

  # test 'admin cannot search for employee username with incorrect password' do
  #   admin1 = employees(:company_admin)
  #   assert_not admin1.search_validate('example@orasi.com', 'wrong_password')
  # end

  test 'employee cannot add an employee' do
    employee1 = employees(:consultant)
    new_employee = employees(:consultant2)
    assert_not employee1.can_add?(new_employee)
  end

  test 'company admin can add employees' do
    admin = employees(:company_admin)
    new_employee = employees(:consultant)
    assert admin.can_add?(new_employee)
  end
end
