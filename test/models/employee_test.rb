require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  test "two employees shouldn't have the same username" do
     e1 = Employee.new
     e2 = Employee.new
     e1.username = "john.doe"
     e1.save
     e2.username = "john.doe"
     assert_raises ActiveRecord::RecordInvalid do
       e2.save!
     end
  end
  
  test "username must be present" do
    e1 = Employee.new
    e1.first_name = "chris"
    e1.last_name = "nolan"
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
  
  test "start date can not be after the current date" do
    e = Employee.new
    e.username = "bob.dylan"
    e.first_name = "bob"
    e.last_name = "dylan"
    e.start_date = DateTime.new(9999,01,01)
    assert_raises ActiveRecord::RecordInvalid do
      e.save!
    end
  end
  
  test "extension must be a valid number" do
    e = Employee.new
    e.username = "bob.dylan"
    e.first_name = "bob"
    e.last_name = "dylan"
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
end
