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
  
  test "username must be present" do
    e1 = Employee.new
    e1.first_name = "chris"
    e1.last_name = "nolan"
    e1.role = "Consultant"
    e1.status = "Permanent"
    e1.email = "chris.nolan@orasi.com"
    assert_raises ActiveRecord::RecordInvalid do
      e1.save!
    end
    assert_nothing_raised ActiveRecord::RecordInvalid do
      e1.username = "chris.nolan"
      e1.save!
    end
  end
  
  test "first_name and last_name must be lowercase" do
    e1 = Employee.new
    e1.username = "rob.stewart"
    e1.first_name = "rob"
    e1.last_name = "stewart"
    e1.email = "rob.stewart@orasi.com"
    e1.role = "Consultant"
    e1.status = "Permanent"
    e1.save!
    assert_raises ActiveRecord::RecordInvalid do
      e1.first_name = "Rob"
      e1.last_name = "stewart"
      e1.save!
    end
    assert_raises ActiveRecord::RecordInvalid do
      e1.first_name = "Rob"
      e1.last_name = "Stewart"
      e1.save!
    end
    assert_raises ActiveRecord::RecordInvalid do
      e1.first_name = "rob"
      e1.last_name = "Stewart"
      e1.save!
    end
    assert_nothing_raised ActiveRecord::RecordInvalid do
      e1.first_name = "rob"
      e1.last_name = "stewart"
      e1.save!
    end
  end
  
  test "start date can be after the current date" do
    e = Employee.new
    e.username = "bob.dylan"
    e.first_name = "bob"
    e.last_name = "dylan"
    e.start_date = Date.new(9999,01,01)
    assert_nothing_raised ActiveRecord::RecordInvalid do
      e.save!
    end
  end
  
  test "extension must be a valid number" do
    e = Employee.new
    e.username = "bob.dylan"
    e.first_name = "bob"
    e.last_name = "dylan"
    e.role = "Consultant"
    e.status = "Permanent"
    e.email = "bob.dylan@orasi.com"
    e.extension = 0
    assert_raises ActiveRecord::RecordInvalid do
      e.save!
    end
    e.extension = -1
    assert_raises ActiveRecord::RecordInvalid do
      e.save!
    end
    e.extension = 999
    assert_raises ActiveRecord::RecordInvalid do
      e.save!
    end
    e.extension = 10000
    assert_raises ActiveRecord::RecordInvalid do
      e.save!
    end
    e.extension = 4000
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
  
  test "all subordinates" do
    consultant = employees(:consultant)
    consultant2 = employees(:consultant2)
    manager2 = employees(:manager2)
    manager = employees(:manager)
    director = employees(:director)
    
    #Test nothing
    assert_nil consultant.all_subordinates
    
    #Test simple case
    assert_equal 1, manager.all_subordinates.count
    assert_equal consultant.id, manager.all_subordinates.first.id
    
    #Test a little more complex
    assert_equal 6, director.all_subordinates.count
    assert director.all_subordinates.include?(manager),  "manager is not included in all subordinates for director"
    assert director.all_subordinates.include?(consultant),  "consultant is not included in all subordinates for director"
    assert director.all_subordinates.include?(manager2),  "manager2 is not included in all subordinates for director"
    assert director.all_subordinates.include?(consultant2),  "consultant2 is not included in all subordinates for director"
  end
  
  test "max vacation days" do
    employee = employees(:consultant)
    
    employee.start_date = Date.current.ago(1)
    assert_equal 10, employee.max_vacation_days
    
    employee.start_date = Date.current.years_ago(4)
    assert_equal 15, employee.max_vacation_days
    
    employee.start_date = Date.current.years_ago(7)
    assert_equal 20, employee.max_vacation_days
    
    employee.start_date = Date.current.years_ago(3).days_since(7)
    assert_equal 10, employee.max_vacation_days
  end
  
  test "roll off date can't be before roll on date" do
    employee = employees(:consultant)
    employee.roll_on_date = Date.current
    employee.roll_off_date = Date.current.ago(1.day)
    assert_not employee.save
  end
  
  test "employee should be allowed to have start year on leap year day" do
    e = employees(:consultant)
    e.email = "bob.barker@orasi.com"
    e.start_date = Date.new(2012,2,29)
    e.save!
  end
end
