class Department < ActiveRecord::Base
  has_many :sub_departments, class_name: 'Department'
  belongs_to :parent_department, class_name: 'Department', foreign_key: 'department_id'
  has_many :top_level_employees, class_name: 'Employee'

  before_destroy :associate_with_parent

  validates :name, uniqueness: { case_sensitive: false }, presence: true
  validate :department_id_not_equal_to_id

  def employees
    Employee.where(id: top_level_employees.pluck(:id) + sub_departments.map do |sub_dept|
      [sub_dept.top_level_employees.pluck(:id)] + sub_dept.employees
    end.flatten.uniq)
  end

  def above?(other_department)
    return false if other_department.blank?

    return true if other_department == self

    self.above? other_department.parent_department
  end

  def find_path_to_highest_department
    if parent_department.blank?
      return [id]
    end

    [id] + parent_department.find_path_to_highest_department
  end

  def department_id_not_equal_to_id
    if !department_id.blank? && !id.blank? && department_id == id
      errors.add(:base, 'Department cannot be its own parent department.')
    end
  end

  private

  def associate_with_parent
    unless sub_departments.blank?
      sub_departments.each do |sub_dept|
        sub_dept.update(department_id: department_id)
      end
    end
  end
end
