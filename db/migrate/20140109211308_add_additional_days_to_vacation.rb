class AddAdditionalDaysToVacation < ActiveRecord::Migration
  def change
    add_column :employees, :additional_days, :integer
  end
end
