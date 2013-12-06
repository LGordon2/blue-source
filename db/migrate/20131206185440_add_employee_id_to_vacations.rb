class AddEmployeeIdToVacations < ActiveRecord::Migration
  def change
    add_column :vacations, :employee_id, :integer
  end
end
