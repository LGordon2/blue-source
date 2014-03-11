class AddExtraMonthsToEmployee < ActiveRecord::Migration
  def change
    add_column :employees, :extra_months, :integer
  end
end
