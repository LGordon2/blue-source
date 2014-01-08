class AddTeamLeadToEmployee < ActiveRecord::Migration
  def change
    add_column :employees, :team_lead, :integer
  end
end
