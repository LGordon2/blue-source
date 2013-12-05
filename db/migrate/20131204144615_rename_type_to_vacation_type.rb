class RenameTypeToVacationType < ActiveRecord::Migration
  def change
    rename_column :vacations, :type, :vacation_type
  end
end
