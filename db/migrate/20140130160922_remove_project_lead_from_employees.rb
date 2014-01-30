class RemoveProjectLeadFromEmployees < ActiveRecord::Migration
  def change
    remove_column :employees, :project_lead, :boolean
  end
end
