module ApplicationHelper
  def capitalize_names_and_projects(employee)
     employee = employee.merge("first_name"=>employee['first_name'].capitalize,
             "last_name"=>employee['last_name'].capitalize)
     employee = employee.merge("project"=>{"name"=>"Not billable"}) if employee['project'].blank?
     unless employee['manager'].nil?
       employee.merge("manager"=>employee['manager'].merge({
         "first_name"=>employee['manager']['first_name'].capitalize,
         "last_name"=>employee['manager']['last_name'].capitalize
       })) 
     else 
       employee 
     end 
  end
end
