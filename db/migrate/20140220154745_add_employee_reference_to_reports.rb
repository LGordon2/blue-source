class AddEmployeeReferenceToReports < ActiveRecord::Migration
  def up
    add_column :reports, :employee_id, :integer
    Report.destroy_all
  end

  def down
    remove_column :reports, :employee_id, :integer
  end
end
