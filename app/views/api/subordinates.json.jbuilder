json.array!(@employee.all_subordinates_for_manager) do |subordinate|
  next if subordinate == @employee
  json.extract! subordinate, :first_name, :last_name, :username, :location
end
