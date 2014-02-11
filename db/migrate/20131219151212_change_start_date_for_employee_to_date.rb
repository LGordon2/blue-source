class ChangeStartDateForEmployeeToDate < ActiveRecord::Migration
  def change
    change_column :employees, :start_date, :date
  end
end
