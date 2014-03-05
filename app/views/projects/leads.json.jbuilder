json.array!(@project.leads.order(first_name: :asc)) do |lead|
	json.extract! lead, :id, :first_name, :last_name
	json.display_name lead.display_name
end