class AddProjectLeadToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :project_lead, :boolean
  end
end
