class ChangeRoles < ActiveRecord::Migration
  def up
    Employee.where(role: "Consultant").update_all(role: "Base")
    Employee.where(role: "Manager").update_all(role: "Management")
    Employee.where(role: "Director").update_all(role: "Upper Management")
    Employee.where(role: "AVP").update_all(role: "Department Head")
    Employee.where(role: "Admin").update_all(role: "Company Admin")
  end
  
  def down
    Employee.where(role: "Base").update_all(role: "Consultant")
    Employee.where(role: "Management").update_all(role: "Manager")
    Employee.where(role: "Upper Management").update_all(role: "Director")
    Employee.where(role: "Department Head").update_all(role: "AVP")
    Employee.where(role: "Company Admin").update_all(role: "Admin")
  end
end
