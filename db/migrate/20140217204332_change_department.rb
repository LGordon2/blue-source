class ChangeDepartment < ActiveRecord::Migration
  def up
    rename_column :employees, :department, :old_department
    Employee.all.each {|e| e.update(department: Department.find_by(name: e.old_department)) unless e.old_department.blank?}
    remove_column :employees, :deparment
  end
  
  def down
    rename_column :employees, :old_department, :department
  end
end
