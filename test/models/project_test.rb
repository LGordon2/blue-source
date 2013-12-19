require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test "project must have a name" do
    p = Project.new
    assert_raises ActiveRecord::RecordInvalid do
      p.save!
    end
    assert_nothing_raised ActiveRecord::RecordInvalid do
      p.name = "Acxiom"
      p.save!
    end
  end
  
  test "start date can be after the current date" do
    p = Project.new
    p.name = "Southern Company"
    p.start_date = DateTime.new(9999,01,01)
    assert_nothing_raised ActiveRecord::RecordInvalid do
      p.save!
    end
  end
  
  test "projected end cannot before start date" do
    p = Project.new
    p.name = "Southern Company"
    p.end_date = DateTime.new(2013,01,01)
    p.start_date = DateTime.new(2014,01,01)
    assert_raises ActiveRecord::RecordInvalid do
      p.save!
    end
  end
  
  test "project assigned lead must have project under their record" do
    p = Project.new
    e = Employee.new
    e.username = "adam.thomas"
    e.first_name = "adam"
    e.last_name = "thomas"
    e.role = "Manager"
    e.status = "Permanent"
    e.email = "adam.thomas@orasi.com"
    e.save!
    p.name = "TitleMax"
    p.lead = e
    p.save!
    assert e.project == p, "The project lead's project is the new project."
  end
end
