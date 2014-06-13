require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  test "employee must have a username" do
    e1 = Employee.new
    assert_raises ActiveRecord::RecordInvalid do
      e1.save!
    end
    assert_raises ActiveRecord::RecordInvalid do
      e1.first_name = "test"
      e1.last_name = "user"
      e1.email = "test.user@orasi.com"
      e1.save!
    end

    assert_nothing_raised ActiveRecord::RecordInvalid do
      e1.username = "test.user"
      e1.save!
    end
  end

  test "employee must have a first and last name" do
    e1 = Employee.new
    assert_raises ActiveRecord::RecordInvalid do
      e1.save!
    end
    assert_raises ActiveRecord::RecordInvalid do
      e1.username = "test.user"
      e1.email = "test.user@orasi.com"
      e1.save!
    end
    assert_raises ActiveRecord::RecordInvalid do
      e1.first_name = "test"
      e1.save!
    end
    assert_raises ActiveRecord::RecordInvalid do
      e1.first_name = nil
      e1.last_name = "user"
      e1.save!
    end
    assert_nothing_raised ActiveRecord::RecordInvalid do
      e1.first_name = "test"
      e1.last_name = "user"
      e1.save!
    end
  end

  test "employee must have an email" do
    e1 = employees(:consultant)

    #First make sure it is ok
    assert_not_nil e1.email

    assert_nothing_raised ActiveRecord::RecordInvalid do
      e1.save!
    end

    #If we try to remove the email a new email should be set for the user
    assert_nothing_raised ActiveRecord::RecordInvalid do
      e1.email = nil
      e1.save!
    end

    assert_not_nil e1.email
  end

  test "if someone tries to set an email it should be a valid email" do
    e1 = employees(:consultant)

    assert_nothing_raised ActiveRecord::RecordInvalid do
      #Base user should be ok.
      e1.save!
    end

    invalid_emails = ["f", 'me@', '@example.com', 'me.example@com', 'me\@example.com']

    invalid_emails.each do |invalid_email|
      e1.email = invalid_email
      assert_not e1.save, e1.email
    end
  end

  test "two employees shouldn't have the same username" do
     e1 = Employee.new
     e2 = Employee.new
     e1.username = "john.doe"
     e1.email = "john.doe@orasi.com"
     e1.save
     e2.username = "john.doe"
     e2.email = "john.doe@orasi.com"
     assert_raises ActiveRecord::RecordInvalid do
       e2.save!
     end
  end
  
  test "start date can be after the current date" do
    e = Employee.new
    e.username = "bob.dylan"
    e.first_name = "bob"
    e.last_name = "dylan"
    e.start_date = Date.new(2099,01,01)
    assert_nothing_raised ActiveRecord::RecordInvalid do
      e.save!
    end
  end

  test "start date cannot be before January 1st, 2000" do
    e = employees(:consultant)

    assert e.save

    e.start_date = Date.new(1999,12,31)
    assert_not e.save, "Able to save start date before Jan 1st, 2000"

    e.start_date = Date.new(2000,1,1)
    assert e.save, "Not able to save start date as Jan 1st, 2000"
  end

  test "start date cannot be after or on January 1st, 2100" do
    e = employees(:consultant)

    assert e.save

    e.start_date = Date.new(2100,1,2)
    assert_not e.save, "Able to save start date after Jan 1st, 2100"

    e.start_date = Date.new(2100,1,1)
    assert_not e.save, "Able to save start date on Jan 1st, 2100"

    e.start_date = Date.new(2099,12,31)
    assert e.save, "Not able to save start date before Jan 1st, 2100"
  end
  
  test "above functionality" do
    consultant = employees(:consultant)
    manager = employees(:manager)
    director = employees(:director)
    
    #Test simple case
    assert manager.above? consultant
    assert_not consultant.above? manager
    
    #Test another simple case
    assert director.above? manager
    assert_not manager.above? director
    
    #Test transitivity
    assert director.above? consultant
    assert_not consultant.above? director
  end
  
  test "max vacation days" do
    employee = employees(:consultant)
    
    employee.start_date = Date.current.ago(1)
    assert_operator 10, '>=', employee.max_vacation_days, "Employee should have less than or 10 days of vacation time."
    
    employee.start_date = Date.current.years_ago(4)
    assert_equal 15, employee.max_vacation_days
    
    employee.start_date = Date.current.years_ago(7)
    assert_equal 20, employee.max_vacation_days
    
    employee.start_date = Date.current.years_ago(3).days_since(7)
    assert_operator 10, "<=", employee.max_vacation_days
  end
  
  test "employee should be allowed to have start year on leap year day" do
    e = employees(:consultant)
    e.email = "bob.barker.2@orasi.com"
    e.start_date = Date.new(2012,2,29)
    e.save!
  end

  test "employee's resources per page must be greater than zero" do
    e = employees(:consultant)

    assert e.save, "Base fixture did not save"

    #Greater than zero is ok.
    100.times do |num|
      e.preferences[:resourcesPerPage] = num+1
      assert e.save, "Did not save with #{num+1}"
    end

    #Zero or less than zero is not ok.
    100.times do |num|
      e.preferences[:resourcesPerPage] = num*-1
      assert_not e.save, "Saved with #{num*-1}"
    end

    #Decimals aren't ok.
    e.preferences[:resourcesPerPage] = 1.1
    assert_not e.save, "Saved with 1.1"
  end

  test "manager cannot be subordinate" do
    e = employees(:consultant)
    m = employees(:manager)

    assert m.above? e
    assert e.manager == m

    m.manager = e

    assert_not m.save, "Employee could be manager's manager"
    Rails.logger.info m.errors
  end
end
