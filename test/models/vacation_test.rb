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
end
