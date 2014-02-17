json.array!(current_user.all_subordinates) do |employee|
  json.extract! employee, :id, :manager_id, :project_id, :status
  json.first_name employee.first_name.capitalize
  json.last_name employee.last_name.capitalize
  unless employee.manager.blank?
	  json.manager do 
	    json.id employee.manager.id
	    json.first_name employee.manager.first_name.capitalize
	    json.last_name employee.manager.last_name.capitalize
	  end
  end
  unless employee.project.blank?
	  json.project do 
	    json.extract! employee.project, :name
	  end
  end
end
