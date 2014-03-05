json.array!(@department.sub_departments) do |sub_dept|
  json.extract! sub_dept, :id, :name, :department_id
end