json.array!(@department.employees.where.not(status: "Inactive")) do |employee|
	json.extract! employee, :id, :first_name, :last_name, :email, :department, :office_phone, :cell_phone, :im_name, :im_client
	json.first_name employee.first_name.capitalize
	json.last_name employee.last_name.capitalize
	json.display_name employee.display_name
	
	unless employee.project.blank?
		json.project do
			json.name employee.project.name
		end
	else
		json.project do
			json.name "Not billable"
		end
	end
	unless employee.department.blank?
		json.department do
			json.name employee.department.name
		end
	end
	unless employee.manager.blank?
		json.manager do
			json.extract! employee.manager, :id, :email
			json.first_name employee.manager.first_name.capitalize
			json.last_name employee.manager.last_name.capitalize
			json.display_name employee.manager.display_name
		end
	end
end