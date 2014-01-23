require 'test_helper'

class VacationHelperTest < ActionView::TestCase
  
  test "should work for holidays in 2014" do
    assert_equal 0,calc_business_days_for_range(Date.new(2014,1,1),Date.new(2014,1,1)) #new years
    assert_equal 0,calc_business_days_for_range(Date.new(2014,5,26),Date.new(2014,5,26))#memorial day
    assert_equal 0,calc_business_days_for_range(Date.new(2014,7,4),Date.new(2014,7,4))#independence day
    assert_equal 0,calc_business_days_for_range(Date.new(2014,9,1),Date.new(2014,9,1))#labor day
    assert_equal 0,calc_business_days_for_range(Date.new(2014,11,27),Date.new(2014,11,27))#thanksgiving
    assert_equal 0,calc_business_days_for_range(Date.new(2014,11,28),Date.new(2014,11,28))#black friday
    assert_equal 0,calc_business_days_for_range(Date.new(2014,12,24),Date.new(2014,12,24))#christmas eve
    assert_equal 0,calc_business_days_for_range(Date.new(2014,12,25),Date.new(2014,12,25))#christmas day
  end
end
