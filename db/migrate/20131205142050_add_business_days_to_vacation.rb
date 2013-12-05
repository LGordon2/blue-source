class AddBusinessDaysToVacation < ActiveRecord::Migration
  def change
    add_column :vacations, :business_days, :integer
  end
end
