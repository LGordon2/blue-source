require 'test_helper'

class VacationTest < ActiveSupport::TestCase
  test "fiscal year calculation" do
    #Test new years
    d = Date.new(2014,8,1)
    assert_equal 2015, Vacation.calculate_fiscal_year(d)
    
    d = Date.new(2014,05,01)
    assert_equal 2015, Vacation.calculate_fiscal_year(d)
    
    d = Date.new(2014,04,30)
    assert_equal 2014, Vacation.calculate_fiscal_year(d)
    
    d = Date.new(2013,12,31)
    assert_equal 2014, Vacation.calculate_fiscal_year(d)
    
    d = Date.new(2014,01,01)
    assert_equal 2014, Vacation.calculate_fiscal_year(d)
  end
  
  test "vacation over fiscal year" do
    v = Vacation.new
    v.start_date = Date.new(2014,04,18)
    v.end_date = Date.new(2014,5,2)
    v.business_days = 11
    v.vacation_type = "Vacation"
    v.employee_id = employees(:consultant).id
    v.manager_id = employees(:manager).id
    assert v.save, "Vacation should restart over the fiscal year"
  end
  
  test "vacation before fiscal year and after fiscal year" do
    v = Vacation.create({start_date: "2014-04-01", end_date: "2014-04-14", business_days: 10, vacation_type: "Vacation", employee_id: employees(:consultant).id, manager_id: employees(:manager).id})
    v2 = Vacation.create({start_date: "2014-05-01", end_date: "2014-05-01", business_days: 1, vacation_type: "Vacation", employee_id: employees(:consultant).id, manager_id: employees(:manager).id})
    assert v.save
    assert v2.save
  end
end
