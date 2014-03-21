class RemoveSomeColumns < ActiveRecord::Migration
  def change
    remove_column :employees, :team_lead_id, :integer
    remove_column :employees, :roll_on_date, :date
    remove_column :employees, :roll_off_date, :date
    remove_column :employees, :project_comments, :text
    remove_column :employees, :scheduled_hours_start, :string
    remove_column :employees, :scheduled_hours_end, :string
    remove_column :employees, :project_id, :integer
  end
end
