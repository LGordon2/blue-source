json.array!(Employee.where.not(status: "Inactive")) do |employee|
  json.extract! employee, :id, :cell_phone, :im_name, :im_client, :email, :office_phone
  json.first_name employee.first_name.capitalize
  json.last_name employee.last_name.capitalize
  json.display_name employee.display_name
  unless employee.manager.blank?
	  json.manager do 
	    json.id employee.manager.id
	    json.first_name employee.manager.first_name.capitalize
	    json.last_name employee.manager.last_name.capitalize
	    json.display_name employee.manager.display_name
	    json.email employee.manager.email
	  end
  end
  unless employee.project.blank?
	  json.project do 
	    json.extract! employee.project, :name
	  end
  else
	  json.project do
	    json.name "Not billable"
	  end
  end
  unless employee.department.blank?
	  json.department do 
	    json.extract! employee.department, :name
	  end
  end
end
