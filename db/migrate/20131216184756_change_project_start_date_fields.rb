class ChangeProjectStartDateFields < ActiveRecord::Migration
  def change
    rename_column :projects, :projected_end, :end_date
    add_column :employees, :roll_on_date, :date
    add_column :employees, :roll_off_date, :date
  end
end
