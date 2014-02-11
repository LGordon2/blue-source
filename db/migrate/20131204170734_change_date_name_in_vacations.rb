class ChangeDateNameInVacations < ActiveRecord::Migration
  def change
    rename_column :vacations, :end, :end_date
    rename_column :vacations, :start, :start_date
  end
end
