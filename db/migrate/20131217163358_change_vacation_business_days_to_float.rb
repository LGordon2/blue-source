class ChangeVacationBusinessDaysToFloat < ActiveRecord::Migration
  def change
    change_column :vacations, :business_days, :float
  end
end
