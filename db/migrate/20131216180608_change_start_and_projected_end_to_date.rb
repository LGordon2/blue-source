class ChangeStartAndProjectedEndToDate < ActiveRecord::Migration
  def change
    change_column :projects, :start_date, :date
    change_column :projects, :projected_end, :date
  end
end
