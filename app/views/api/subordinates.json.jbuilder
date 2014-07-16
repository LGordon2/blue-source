json.array!(@employee.all_subordinates) do |subordinate|
  json.extract! subordinate, :first_name, :last_name, :username
end