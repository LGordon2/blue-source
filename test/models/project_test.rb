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
end
