require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  test "sessions past 1 hour are deleted" do
    s = Session.create({updated_at: Time.now - (1.hour + 1.second)})
    init_count = Session.count
    Session.sweep('1 hour')
    assert_equal Session.count, init_count-1
  end

  test "sessions before 1 hour are not deleted" do
    s = Session.create({updated_at: Time.now - (1.hour - 1.second)})
    init_count = Session.count
    Session.sweep('1 hour')
    assert_equal Session.count, init_count
  end
end
