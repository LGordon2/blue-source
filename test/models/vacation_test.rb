require 'test_helper'
include EmployeeHelper

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
    #assert v.save, "Vacation should restart over the fiscal year"
  end
  
  test "vacation before fiscal year and after fiscal year" do
    v = Vacation.create({date_requested: "2014-04-01", start_date: "2014-04-01", end_date: "2014-04-14", business_days: 10, vacation_type: "Vacation", employee_id: employees(:consultant).id, manager_id: employees(:manager).id})
    v2 = Vacation.create({date_requested: "2014-04-01", start_date: "2014-05-01", end_date: "2014-05-01", business_days: 1, vacation_type: "Vacation", employee_id: employees(:consultant).id, manager_id: employees(:manager).id})
    assert v.save
    assert v2.save
  end
  
  test "try out new date validation" do
    v1 = Vacation.new
    e1 = employees(:consultant)
    manager = employees(:manager)
    v1.date_requested = "2014-04-01"
    v1.start_date = "2014-04-01"
    v1.end_date = "2014-04-01"
    v1.vacation_type = "Sick"
    v1.employee = e1
    v1.manager = manager
    assert v1.save
    assert_equal 1, v1.business_days
    assert_equal 1, e1.sick_days_taken(v1.start_date)
    assert v1.destroy
    assert_equal 0, e1.sick_days_taken(v1.start_date)
    
    v1 = Vacation.create({date_requested: "2013-12-02", start_date: "2013-12-02", end_date: "2013-12-13", vacation_type: "Vacation", employee: e1, manager: manager})
    assert v1.save, "Vacation should have been saved"
    assert_equal 10, v1.business_days
    assert_equal 10, e1.vacation_days_taken(v1.start_date)
    assert v1.destroy
    assert_equal 0, e1.vacation_days_taken(v1.start_date)
    
    v1 = Vacation.create({date_requested: "2013-12-02", start_date: "2013-12-02", end_date: "2013-12-12", vacation_type: "Vacation", employee: e1, manager: manager})
    v2 = Vacation.create({date_requested: "2013-12-13", start_date: "2013-12-13", end_date: "2013-12-13", vacation_type: "Vacation", employee: e1, manager: manager, half_day: true})
    v3 = Vacation.create({date_requested: "2013-12-16", start_date: "2013-12-16", end_date: "2013-12-16", vacation_type: "Vacation", employee: e1, manager: manager, half_day: true})
    assert v1.save, "Vacation should have been saved"
    assert v2.save, "Vacation should have been saved"
    assert v3.save, "Vacation should have been saved"
    assert_equal 0.5, v2.business_days, "Business days calculation"
    assert_equal 10, e1.vacation_days_taken(v2.start_date), "Vacation days taken"
    assert_equal special_vacation_round(8*0.83+4*1.25), e1.max_vacation_days(v2.start_date), "Checking max vacation days for employee with start date [#{e1.start_date}] and date is [#{v2.start_date}]"
    v4 = Vacation.create({date_requested: "2013-12-17", start_date: "2013-12-17", end_date: "2013-12-17", vacation_type: "Vacation", employee: e1, manager: manager, half_day: true})
    assert v1.destroy
    assert v2.destroy
    assert v3.destroy
    assert v4.destroy
    assert_equal 0, e1.vacation_days_taken(v1.start_date), "Reset"
    
    v1 = Vacation.create({date_requested: "2013-12-05", start_date: "2013-12-05", end_date: "2013-12-19", vacation_type: "Vacation", employee: e1, manager: manager})
    assert v1.save, "Vacation should have been saved"
    assert_equal 11, v1.business_days
    assert_equal 11, e1.vacation_days_taken(v1.start_date)
    assert v1.destroy
    assert_equal 0, e1.vacation_days_taken(v1.start_date)
    
    v1 = Vacation.create({date_requested: "2013-12-05", start_date: "2013-12-05", end_date: "2013-12-23", vacation_type: "Vacation", employee: e1, manager: manager})
    assert v1.save, "Vacation should have been saved"
    assert_equal 13, v1.business_days
    assert v1.destroy
    assert_equal 0, e1.vacation_days_taken(v1.start_date)
    
    v1 = Vacation.create({date_requested: "2014-04-17", start_date: "2014-04-17", end_date: "2014-05-01", vacation_type: "Vacation", employee: e1, manager: manager})
    assert v1.save, "Vacation should have been saved"
    assert_equal 11, v1.business_days
    assert_equal 10, e1.vacation_days_taken(v1.start_date)
    assert v1.destroy
    assert_equal 0, e1.vacation_days_taken(v1.start_date)
    
    v1 = Vacation.create({date_requested: "2014-04-17", start_date: "2014-04-17", end_date: "2014-05-21", vacation_type: "Vacation", employee: e1, manager: manager})
    assert v1.save, "Vacation should have been saved"
    assert_equal 25, v1.business_days
    assert_equal 10, e1.vacation_days_taken(v1.start_date)
    assert_equal 15, e1.vacation_days_taken(Date.new(v1.start_date.year+1, v1.start_date.month, v1.start_date.day))
    assert v1.destroy
    assert_equal 0, e1.vacation_days_taken(v1.start_date)
    
    v1 = Vacation.create({date_requested: "2014-04-17", start_date: "2014-04-17", end_date: "2014-05-22", vacation_type: "Vacation", employee: e1, manager: manager})
    assert v1.save, "Vacation should have been saved"
    assert_equal 26, v1.business_days
    assert v1.destroy
    assert_equal 0, e1.vacation_days_taken(v1.start_date)
  end
end
