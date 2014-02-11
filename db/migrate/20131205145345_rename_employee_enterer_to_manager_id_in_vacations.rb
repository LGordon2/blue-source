class RenameEmployeeEntererToManagerIdInVacations < ActiveRecord::Migration
  def change
    rename_column :vacations, :employee_enterer, :manager_id
  end
end
