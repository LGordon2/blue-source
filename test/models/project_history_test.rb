require 'test_helper'

class ProjectHistoryTest < ActiveSupport::TestCase
  test 'roll off date cannot be before roll on date' do
    project = projects(:one)
    employee = employees(:consultant)

    assert_not_nil project
    assert_not_nil employee

    p = ProjectHistory.create(
                                  project: project,
                                  employee: employee,
                                  roll_on_date: Date.current,
                                  roll_off_date: Date.current - 1.day
                              )

    # Roll on date before roll off date
    p.update(roll_on_date: Date.current, roll_off_date: Date.current - 1.day)
    assert_not p.valid?, p.errors.full_messages

    # Roll on date equals roll off date
    p.update(roll_on_date: Date.current, roll_off_date: Date.current)
    assert p.valid?, p.errors.full_messages

    # Roll on date after roll off date
    p.update(roll_on_date: Date.current, roll_off_date: Date.current + 1.day)
    assert p.valid?, p.errors.full_messages
  end

  test 'maximum and minimum dates' do
    minimum_date = Date.new(2000)
    maximum_date = Date.new(2100)
    project = projects(:one)
    employee = employees(:manager)

    assert_not_nil project
    assert_not_nil employee

    p = ProjectHistory.create(
                                  project: project,
                                  employee: employee,
                                  roll_on_date: Date.current,
                                  roll_off_date: Date.current - 1.day
                              )

    # Roll on date is before minimum date
    p.update(roll_on_date: minimum_date - 1.day)
    assert_not p.valid?, 'Able to set the roll on day before the minimum date'

    # Roll on date is after minimum date and before maximum date
    p.update(roll_on_date: minimum_date + 1.day)
    assert p.valid?, p.errors.full_messages

    # Roll on date is after maximum date
    p.update(roll_on_date: maximum_date + 1.day, roll_off_date: maximum_date + 2.days)
    assert_not p.valid?, 'Able to set the roll on day after the maximum date'

    # Reset date to something valid
    p.update(roll_on_date: Date.current, roll_off_date: Date.current + 1.day)
    assert p.valid?, 'Current date is not valid for the roll on date'

    # Roll off date is after maximum date
    p.update(roll_off_date: maximum_date + 1.day)
    assert_not p.valid?, 'Able to set the roll off day after the maximum date'

    # Roll off date is before minimum date
    p.update(roll_on_date: minimum_date - 2.days, roll_off_date: minimum_date - 1.day)
    assert_not p.valid?, 'Able to set the roll off day before the minimum date'
  end
end
