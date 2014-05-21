class ChangeExtraMonthsToBridgeTime < ActiveRecord::Migration
  def change
    rename_column :employees, :extra_months, :bridge_time
  end
end
