class AddSysAdminFlagToEmployee < ActiveRecord::Migration
  def change
    add_column :employees, :sys_admin, :boolean
  end
end
