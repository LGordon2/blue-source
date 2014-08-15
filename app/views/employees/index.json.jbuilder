json.array!(current_user.all_subordinates) do |employee|
  json.extract! employee, :id, :manager_id, :status
  json.first_name employee.first_name.capitalize
  json.last_name employee.last_name.capitalize
  json.display_name employee.display_name
  json.location employee.location
  json.title employee.title
  unless employee.manager.blank?
	  json.manager do
	    json.id employee.manager.id
	    json.first_name employee.manager.first_name.capitalize
	    json.last_name employee.manager.last_name.capitalize
	    json.display_name employee.manager.display_name
	  end
  end
  json.project do
    if employee.current_project.present?
      json.extract! employee.current_project, :name, :id
    else
      json.name 'Not billable'
      json.id nil
    end
  end
end
