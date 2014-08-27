require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  def setup
    @consultant = employees(:consultant)
    @rural = departments(:rural)
    @services = departments(:services)
    @sub_rural = departments(:sub_rural)
  end

  test 'smoke test for employees' do
    assert_includes @rural.employees, @consultant
    assert_includes @services.employees, @consultant
  end

  test 'find path from lower dept to most parent department' do
    assert_equal @rural.find_path_to_highest_department, [@rural.id, @services.id]
  end

  test 'department cannot be its own parent department' do
    @rural.parent_department = @rural
    assert_not @rural.save
  end

  test 'parent association maintained upon deletion' do
    assert @rural.parent_department == @services
    assert @sub_rural.parent_department == @rural
    Department.find(@rural.id).destroy
    assert Department.find(@sub_rural.id).parent_department == @services
  end
end
