json.array!(Project.all) do |project|
	json.extract! project, :id, :name, :status
	unless project.leads.blank?
		json.leads do
			json.array!(project.leads) do |lead|
				json.extract! lead, :id, :first_name, :last_name
			end
		end 
	else
		json.leads []
	end
	unless project.client_partner.blank?
		json.client_partner do
			json.extract! project.client_partner, :id, :first_name, :last_name
			json.display_name project.client_partner.display_name
		end
	end
	json.all_leads project.leads.collect {|l| l.display_name }.join(", ")
end