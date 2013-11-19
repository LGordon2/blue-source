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
end
