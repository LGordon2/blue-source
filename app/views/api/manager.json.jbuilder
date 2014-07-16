json.extract! @employee.manager, :first_name, :last_name, :username, :location unless @employee.manager.blank?
