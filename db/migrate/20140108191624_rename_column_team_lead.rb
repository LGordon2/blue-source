class RenameColumnTeamLead < ActiveRecord::Migration
  def change
    rename_column :employees, :team_lead, :team_lead_id
  end
end
