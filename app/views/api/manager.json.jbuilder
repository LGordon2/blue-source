json.extract! @employee.manager, :first_name, :last_name, :username unless @employee.manager.blank?
