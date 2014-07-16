json.array!(@employee.all_subordinates) do |subordinate|
  next if subordinate == @employee
  json.extract! subordinate, :first_name, :last_name, :username
end
