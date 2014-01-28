class RemoveAdditionalDaysColumn < ActiveRecord::Migration
  def change
    remove_column :employees, :additional_days, :integer
  end
end
