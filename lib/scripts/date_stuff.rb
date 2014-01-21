require 'test/unit/assertions'
include Test::Unit::Assertions
include ActionView::Helpers::TextHelper
include VacationHelper

assert_equal 2, Date.new(2015,1,1).distance_in_years(Date.new(2012,2,29)), "Before anniversary hits"
assert_equal 3, Date.new(2015,2,28).distance_in_years(Date.new(2012,2,29)), "Leap year condition"
assert_equal 3, Date.new(2015,3,1).distance_in_years(Date.new(2012,2,29)), "After anniversary hits"

assert_equal PTO.accrual_rates(0), PTO.accrued_vacation_days_on_date(Date.new(2014,5,1)), "Basic test"
assert_equal PTO.accrual_rates(0)*2, PTO.accrued_vacation_days_on_date(Date.new(2014,6,1)), "Two months"
assert_equal PTO.accrual_rates(0), PTO.accrued_vacation_days_on_date(Date.new(2014,5,1),Date.new(2014,3,1)), "Basic test with anniversary date"
assert_equal PTO.accrual_rates(0), PTO.accrued_vacation_days_on_date(Date.new(2014,2,1),Date.new(2014,1,2)), "Starting day after previous fiscal new year"
assert_equal PTO.accrual_rates(2)*2+PTO.accrual_rates(3), PTO.accrued_vacation_days_on_date(Date.new(2014,7,1),Date.new(2011,6,1))
assert_equal PTO.accrual_rates(2)*2+PTO.accrual_rates(3)*2, PTO.accrued_vacation_days_on_date(Date.new(2014,8,1),Date.new(2011,6,1))
assert_equal PTO.accrual_rates(5)*2+PTO.accrual_rates(6)*2, PTO.accrued_vacation_days_on_date(Date.new(2014,8,1),Date.new(2008,6,1))
assert_equal PTO.accrual_rates(5)*4+PTO.accrual_rates(6)*2, PTO.accrued_vacation_days_on_date(Date.new(2014,10,25),Date.new(2008,8,24))

assert Date.new(2013,11,28).thanksgiving?
assert_equal 2014, calculate_fiscal_year
