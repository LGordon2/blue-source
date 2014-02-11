class RemoveLeadIdFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :lead_id
  end
end
