class AddEmployeeEnterIdToVacations < ActiveRecord::Migration
  def change
    add_column :vacations, :employee_enterer, :integer
  end
end
