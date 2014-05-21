require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
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
end
