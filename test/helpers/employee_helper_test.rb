require 'test_helper'

class EmployeeHelperTest < ActionView::TestCase
  test 'accrued vacation days on date' do
    assert_equal 2.5, accrued_vacation_days_on_date(Date.new(2014, 7, 2), Date.new(2011, 7, 2))
  end
end
